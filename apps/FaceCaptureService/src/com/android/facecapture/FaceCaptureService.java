/*
 * vivo 1907N Face Unlock bring-up, Фаза 3 (not AOSP).
 *
 * This is the capture-side counterpart to the framework wiring added in Фаза 2
 * (Face10.java's startFaceCapture()/stopFaceCapture()/scheduleGetShareMemoryFd()/
 * scheduleSendCommand()). Package name (com.android.facecapture) and this class's
 * name/location are fixed there - Face10.java starts and stops this exact component via a bare
 * Intent(ComponentName) (plus, since the live-preview addition, a single optional
 * EXTRA_PREVIEW_SURFACE extra - see mPreviewSurface's field comment), so this service gets no
 * sensorId, resolution, or any other parameter from its caller; those are hardcoded below to
 * match what Фаза 4 registered in config_biometric_sensors (sensorId=1, matching stock
 * Funtouch's own framework-res.apk "1:8:4095" entry - see
 * device/vivo/1907N/overlay/.../config.xml's config_biometric_sensors comment).
 *
 * Protocol (see hardware/vivo/interfaces/biometrics/face/2.0/IBiometricsFace.hal and
 * FaceManager.getShareMemoryFd()/sendCommand() for the full reverse-engineered rationale):
 *   1. FaceManager.getShareMemoryFd(sensorId, size) once, where size is exactly the NV21 byte
 *      length for our chosen capture resolution (width*height*3/2) - the framework allocates
 *      (or reuses) shared memory of that size and hands back a dup'd fd, kept open for the
 *      capture session's lifetime.
 *   2. Write frames via a real mmap done in JNI (libfacecaptureshm, see jni/facecapture_jni.c),
 *      not any pure-Java approach - two were tried on-device and both failed for ashmem-specific
 *      reasons: (a) Os.pwrite() on this fd fails with EINVAL on every single call - ashmem-backed
 *      shared memory (what SharedMemory.create() hands back here) only implements mmap()/ioctl()
 *      at the kernel driver level, not read()/write() at all; (b) java.nio.FileChannel.map()
 *      (even after reopening the fd via /proc/self/fd/<n> to get a dual readable+writable
 *      channel, since a plain FileInputStream/FileOutputStream-derived one is only ever one or
 *      the other) *also* fails with EINVAL, because it internally fstat()s the fd first and,
 *      seeing size 0 (ashmem's real size lives behind the ASHMEM_GET_SIZE ioctl, not st_size),
 *      tries to ftruncate() it to match - which ashmem rejects too, since its size is fixed at
 *      creation. android.os.SharedMemory itself sidesteps all of this by calling Os.mmap()
 *      directly and wrapping the returned address in a java.nio.DirectByteBuffer via a
 *      package-private constructor - a core-platform-api symbol restricted even from
 *      platform-signed regular apps like this one (a stricter boundary than ordinary framework
 *      @hide/@SystemApi). JNI's NewDirectByteBuffer() gets us the same kind of address-backed
 *      ByteBuffer without needing that restricted constructor at all - it's part of the JNI
 *      spec, not subject to any Android hidden-API allowlist.
 *   3. Per captured frame: convert Camera2's YUV_420_888 Image to tightly-packed NV21 (no
 *      header), write it into the mapped region, then FaceManager.sendCommand(sensorId,
 *      CMD_HIDL_WRITE_FACE_DATA, 0, "face"). The framework pushes the shared-memory handle to
 *      the HAL on our first sendCommand of each session automatically - we never call
 *      anything HIDL-facing ourselves.
 *   4. Real per-frame result (face found / not found / quality too low / enrolled / etc.)
 *      arrives asynchronously to Face10's HalResultController.onFaceAlgorithmResult(), not
 *      back to us - this service has no feedback channel and doesn't need one, it's a dumb
 *      frame pump.
 *
 * Unverified/best-guess values, documented as such rather than silently assumed correct (same
 * convention as the rest of this device tree's RE work - see FINGERPRINT_ALGORITHM_MAP.md for
 * the pattern this follows):
 *   - CAPTURE_WIDTH/HEIGHT (640x480): Фаза 0 only pinned down the pixel *format* (NV21), not a
 *     resolution. 640x480 is a conservative default (universally supported by front cameras,
 *     fast for face-landmark-style processing) - not derived from any stock artifact.
 *   - "extra" argument to sendCommand: hardcoded to 0. This one IS grounded, not guessed -
 *     Face10.java's scheduleSendCommand() doc comment records that the decompiled real capture
 *     app always sends extra=0 too.
 */
package com.android.facecapture;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.face.FaceManager;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import android.view.Surface;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicBoolean;

public class FaceCaptureService extends Service {
    private static final String TAG = "FaceCaptureService";

    private static final int SENSOR_ID = 1;
    private static final int CMD_HIDL_WRITE_FACE_DATA = 0x3ea;

    private static final int CAPTURE_WIDTH = 640;
    private static final int CAPTURE_HEIGHT = 480;
    private static final int NV21_SIZE = CAPTURE_WIDTH * CAPTURE_HEIGHT * 3 / 2;

    // The vendor daemon's sendhandle() does NOT use the size we pass through the NativeHandle's
    // int array at all - confirmed via Ghidra disassembly of the real binary
    // (vendor.vivo.hardware.biometrics.face@2.0-service): it builds its own local hidl_memory on
    // the stack with a HARDCODED mSize of 0x713b8 (463800) bytes, then calls
    // android::hardware::mapMemory() on that, which ends up in AshmemMapper::mapMemory()
    // (system/libhidl/transport/memory/1.0/default/AshmemMapper.cpp) doing
    // mmap(0, mem.size(), ..., fd, 0). ashmem's mmap rejects a requested length larger than the
    // region's real size, so as long as our ashmem region was only NV21_SIZE (460800) bytes, that
    // mmap failed silently (AshmemMapper logs nothing on MAP_FAILED) - this is the actual cause
    // of the "mapMemory Fiald!!" the daemon has been logging every session. Sizing our allocation
    // to at least this hardcoded value unblocks the mmap; see FACE_UNLOCK_STATUS.md.
    private static final int VENDOR_MAPPED_MEMORY_SIZE = 0x713b8;

    // vivo 1907N Face Unlock bring-up (not AOSP): live self-view preview, see
    // Face10.java's scheduleSetPreviewSurface(). Plain string literal, not a shared constant -
    // Face10.java lives in a completely different app/build module (frameworks/base) that this
    // app can't depend on, see that file's matching comment on the same key.
    private static final String EXTRA_PREVIEW_SURFACE =
            "com.android.facecapture.extra.PREVIEW_SURFACE";

    // vivo 1907N Face Unlock bring-up (not AOSP): every frame, full rate - was throttled to
    // every 3rd frame at one point, on the theory that preview rendering's own CPU cost
    // (JPEG encode+decode+rotate/mirror+Canvas draw, per onImageAvailable() frame) was
    // contributing to the "Slow dispatch"/button-freeze issue. The real cause of that turned out
    // to be unrelated - see FACE_UNLOCK_STATUS.md's Фаза 7 (BiometricScheduler taking minutes to
    // actually call stopFaceCapture(), now fixed by calling it directly and immediately instead
    // of waiting on that). Rendering still runs on its own lower-priority thread
    // (mPreviewHandler), so it can't compete with/block the camera-to-HAL pipeline on
    // mCameraHandler regardless of rate.
    private static final int PREVIEW_FRAME_SKIP = 1;
    private int mPreviewFrameCounter;

    private HandlerThread mCameraThread;
    private Handler mCameraHandler;
    private HandlerThread mPreviewThread;
    private Handler mPreviewHandler;
    private CameraManager mCameraManager;
    private CameraDevice mCameraDevice;
    private CameraCaptureSession mCaptureSession;
    private ImageReader mImageReader;
    private static final String NOTIFICATION_CHANNEL_ID = "face_capture";
    private static final int NOTIFICATION_ID = 1;

    static {
        System.loadLibrary("facecaptureshm");
    }

    // See jni/facecapture_jni.c - raw mmap()/munmap() via JNI, needed because ashmem (what
    // FaceManager.getShareMemoryFd() hands back) doesn't support any pure-Java mapping approach
    // available to a regular app on this AOSP branch (see allocateShareMemory()'s comment and
    // the class doc comment for the two Java approaches that were tried and failed on-device).
    private static native ByteBuffer nativeMmap(int fd, int size);
    private static native void nativeMunmap(ByteBuffer buffer, int size);

    private FaceManager mFaceManager;
    private ParcelFileDescriptor mShareMemoryPfd;
    private ByteBuffer mShareMemoryBuffer;
    private byte[] mNv21Buffer;
    private final AtomicBoolean mCapturing = new AtomicBoolean(false);

    // vivo 1907N Face Unlock bring-up (not AOSP): live self-view preview surface, handed over by
    // Face10.java (originally from FaceEnrollPreviewFragment's TextureView, see
    // FaceManager.setPreviewSurface()). Rendered into directly from onImageAvailable() via
    // Canvas, not via a second Camera2 capture-session target - we already own the camera and
    // already have each frame as an Image here, so there's no need to juggle multiple session
    // outputs or hand the camera itself to another process. Reused JPEG scratch buffer to avoid
    // a per-frame allocation.
    private volatile Surface mPreviewSurface;
    private final ByteArrayOutputStream mJpegScratch = new ByteArrayOutputStream(32 * 1024);
    // vivo 1907N Face Unlock bring-up (not AOSP): a stable copy of the NV21 frame handed off to
    // mPreviewHandler - mNv21Buffer itself gets overwritten by the next frame as soon as
    // onImageAvailable() returns, so rendering from it asynchronously on a different thread would
    // race. mPreviewRenderInFlight guards against a new copy landing here while mPreviewHandler
    // is still reading the previous one back - not a full lock, just enough to keep this from
    // ever having more than one render in flight at a time under sustained CPU pressure.
    private final byte[] mPreviewNv21Buffer = new byte[NV21_SIZE];
    private final AtomicBoolean mPreviewRenderInFlight = new AtomicBoolean(false);
    // vivo 1907N Face Unlock bring-up (not AOSP): diagnostic only, logs on transitions rather
    // than every frame - tracking down a reported live-preview freeze mid-enrollment.
    private boolean mLastPreviewSurfaceUsable;
    private int mRenderedFrameCount;
    private int mImageAvailableCount;

    // vivo 1907N Face Unlock bring-up (not AOSP): front camera's CameraCharacteristics.
    // SENSOR_ORIENTATION, read once in openCamera(). The sensor is physically mounted rotated
    // relative to the device's natural (portrait) orientation - Camera2's raw buffers come out
    // in the sensor's own landscape-native orientation, and only a client that explicitly
    // compensates for this (like Settings' preview normally would, via TextureView's transform)
    // sees an upright image. Used only by renderPreviewFrame() - see openCamera()'s comment for
    // why the HAL-facing frames are deliberately left uncorrected.
    private volatile int mSensorOrientation;

    @Override
    public void onCreate() {
        super.onCreate();
        mFaceManager = getSystemService(FaceManager.class);
        mCameraManager = getSystemService(CameraManager.class);
        mNv21Buffer = new byte[NV21_SIZE];
        mCameraThread = new HandlerThread("FaceCaptureCamera");
        mCameraThread.start();
        mCameraHandler = new Handler(mCameraThread.getLooper());
        // See PREVIEW_FRAME_SKIP's comment - background priority so this can't compete with the
        // camera-to-HAL pipeline under CPU pressure.
        mPreviewThread = new HandlerThread("FaceCapturePreview",
                android.os.Process.THREAD_PRIORITY_BACKGROUND);
        mPreviewThread.start();
        mPreviewHandler = new Handler(mPreviewThread.getLooper());
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Must promote to foreground within 5s of starting or the system kills us - see
        // Face10.java's startFaceCapture() for why this has to be a foreground service at all
        // (plain startService() was silently rejected with
        // BackgroundServiceStartNotAllowedException, confirmed via a real device logcat: the
        // service never started, no camera ever opened, no frames ever reached the HAL). Done
        // first, before any of the checks below, so it happens unconditionally and promptly.
        startForeground(NOTIFICATION_ID, buildNotification());
        // vivo 1907N Face Unlock bring-up: read on every single start, including a re-delivery
        // to an already-capturing instance - this is how Face10.java gets an updated (or newly
        // available) preview surface to us without restarting the camera/share-memory session,
        // see Face10.java's scheduleSetPreviewSurface(). May legitimately be null (no preview
        // fragment visible, or it hasn't called setPreviewSurface() yet).
        // getParcelableExtra(String, Class) needs API 33 - this branch targets API 32.
        mPreviewSurface = intent == null ? null
                : intent.getParcelableExtra(EXTRA_PREVIEW_SURFACE);
        Log.i(TAG, "onStartCommand: capturing=" + mCapturing.get() + " previewSurface="
                + mPreviewSurface + " valid="
                + (mPreviewSurface != null && mPreviewSurface.isValid()));
        if (mFaceManager == null) {
            Log.e(TAG, "onStartCommand: no FaceManager, stopping");
            stopSelf();
            return START_NOT_STICKY;
        }
        if (checkSelfPermission(android.Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "onStartCommand: no CAMERA permission, stopping");
            stopSelf();
            return START_NOT_STICKY;
        }
        if (!mCapturing.compareAndSet(false, true)) {
            // Already running a capture session - this was just a preview-surface update
            // (handled above), not a fresh start. Don't reallocate share memory or reopen the
            // camera on top of an already-running session.
            return START_NOT_STICKY;
        }
        if (!allocateShareMemory()) {
            mCapturing.set(false);
            stopSelf();
            return START_NOT_STICKY;
        }
        mCameraHandler.post(this::openCamera);
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        mCapturing.set(false);
        // We never owned this Surface (FaceEnrollPreviewFragment does) - just drop the
        // reference, don't release() it ourselves.
        mPreviewSurface = null;
        closeCamera();
        if (mShareMemoryBuffer != null) {
            nativeMunmap(mShareMemoryBuffer, VENDOR_MAPPED_MEMORY_SIZE);
            mShareMemoryBuffer = null;
        }
        if (mShareMemoryPfd != null) {
            try {
                mShareMemoryPfd.close();
            } catch (java.io.IOException e) {
                Log.w(TAG, "Failed to close face capture shared memory fd", e);
            }
            mShareMemoryPfd = null;
        }
        mCameraThread.quitSafely();
        mPreviewThread.quitSafely();
        super.onDestroy();
    }

    private boolean allocateShareMemory() {
        // Sized to VENDOR_MAPPED_MEMORY_SIZE (463800), not NV21_SIZE (460800) - see that
        // constant's comment. The extra 3000 bytes past the NV21 payload are currently left
        // zeroed/unwritten; whether the daemon expects a header there is still open.
        ParcelFileDescriptor pfd = mFaceManager.getShareMemoryFd(SENSOR_ID,
                VENDOR_MAPPED_MEMORY_SIZE);
        if (pfd == null) {
            Log.e(TAG, "getShareMemoryFd returned null");
            return false;
        }
        // Kept open for the whole capture session, closed in onDestroy(). See the class doc
        // comment for why the mapping itself has to go through JNI (nativeMmap) rather than any
        // pure-Java approach - ashmem doesn't support what either of the two Java options tried
        // on-device needed.
        mShareMemoryPfd = pfd;
        mShareMemoryBuffer = nativeMmap(pfd.getFd(), VENDOR_MAPPED_MEMORY_SIZE);
        if (mShareMemoryBuffer == null) {
            Log.e(TAG, "nativeMmap failed for face capture shared memory");
            return false;
        }
        return true;
    }

    private String findFrontCameraId() {
        try {
            for (String id : mCameraManager.getCameraIdList()) {
                CameraCharacteristics chars = mCameraManager.getCameraCharacteristics(id);
                Integer facing = chars.get(CameraCharacteristics.LENS_FACING);
                if (facing != null && facing == CameraCharacteristics.LENS_FACING_FRONT) {
                    return id;
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to enumerate cameras", e);
        }
        return null;
    }

    private void openCamera() {
        String cameraId = findFrontCameraId();
        if (cameraId == null) {
            Log.e(TAG, "No front-facing camera found, stopping");
            stopSelf();
            return;
        }
        // vivo 1907N Face Unlock bring-up (not AOSP): needed only for the preview render (see
        // renderPreviewFrame()) - the vendor face HAL was already receiving un-rotated frames
        // this whole time (enrollment/unlock both confirmed working before the preview was ever
        // added), so this correction is intentionally NOT applied to mNv21Buffer/the HAL path,
        // only to the separate preview Bitmap - don't "fix" the HAL frames to match, that path is
        // proven working as-is.
        try {
            CameraCharacteristics chars = mCameraManager.getCameraCharacteristics(cameraId);
            Integer orientation = chars.get(CameraCharacteristics.SENSOR_ORIENTATION);
            mSensorOrientation = orientation != null ? orientation : 0;
        } catch (Exception e) {
            Log.w(TAG, "Failed to read SENSOR_ORIENTATION, assuming 0", e);
            mSensorOrientation = 0;
        }
        mImageReader = ImageReader.newInstance(
                CAPTURE_WIDTH, CAPTURE_HEIGHT, ImageFormat.YUV_420_888, /* maxImages */ 2);
        mImageReader.setOnImageAvailableListener(this::onImageAvailable, mCameraHandler);
        try {
            mCameraManager.openCamera(cameraId, new CameraDevice.StateCallback() {
                @Override
                public void onOpened(CameraDevice device) {
                    mCameraDevice = device;
                    startCaptureSession();
                }

                @Override
                public void onDisconnected(CameraDevice device) {
                    device.close();
                    mCameraDevice = null;
                    stopSelf();
                }

                @Override
                public void onError(CameraDevice device, int error) {
                    Log.e(TAG, "Camera error: " + error);
                    device.close();
                    mCameraDevice = null;
                    stopSelf();
                }
            }, mCameraHandler);
        } catch (Exception e) {
            Log.e(TAG, "Failed to open front camera", e);
            stopSelf();
        }
    }

    private void startCaptureSession() {
        if (mCameraDevice == null) return;
        try {
            CaptureRequest.Builder requestBuilder = mCameraDevice.createCaptureRequest(
                    CameraDevice.TEMPLATE_PREVIEW);
            requestBuilder.addTarget(mImageReader.getSurface());
            mCameraDevice.createCaptureSession(
                    java.util.Collections.singletonList(mImageReader.getSurface()),
                    new CameraCaptureSession.StateCallback() {
                        @Override
                        public void onConfigured(CameraCaptureSession session) {
                            mCaptureSession = session;
                            try {
                                session.setRepeatingRequest(
                                        requestBuilder.build(), null, mCameraHandler);
                            } catch (Exception e) {
                                Log.e(TAG, "Failed to start repeating capture request", e);
                                stopSelf();
                            }
                        }

                        @Override
                        public void onConfigureFailed(CameraCaptureSession session) {
                            Log.e(TAG, "Camera capture session configuration failed");
                            stopSelf();
                        }
                    }, mCameraHandler);
        } catch (Exception e) {
            Log.e(TAG, "Failed to create capture session", e);
            stopSelf();
        }
    }

    private void onImageAvailable(ImageReader reader) {
        if (!mCapturing.get()) {
            return;
        }
        // vivo 1907N Face Unlock bring-up (not AOSP): diagnostic heartbeat, every 10th raw camera
        // callback - separate from renderPreviewFrame()'s own heartbeat, to tell apart "the camera
        // itself stopped delivering frames" from "frames keep arriving but rendering into the
        // preview Surface specifically stalls" during the reported freeze.
        mImageAvailableCount++;
        if (mImageAvailableCount % 10 == 0) {
            Log.i(TAG, "onImageAvailable: callback #" + mImageAvailableCount);
        }
        Image image = reader.acquireLatestImage();
        if (image == null) {
            Log.w(TAG, "onImageAvailable: acquireLatestImage returned null (#"
                    + mImageAvailableCount + ")");
            return;
        }
        try {
            imageToNv21(image, mNv21Buffer);
            // Always overwrite from the start of the mapping, one frame at a time.
            mShareMemoryBuffer.position(0);
            mShareMemoryBuffer.put(mNv21Buffer);
            mFaceManager.sendCommand(SENSOR_ID, CMD_HIDL_WRITE_FACE_DATA, 0, "face");
        } catch (RuntimeException e) {
            Log.e(TAG, "Failed to write frame into face capture shared memory", e);
        } finally {
            image.close();
        }
        maybeQueuePreviewFrame();
    }

    // vivo 1907N Face Unlock bring-up (not AOSP): throttles and hands off to mPreviewHandler -
    // see PREVIEW_FRAME_SKIP's and mPreviewNv21Buffer's comments for why. The copy itself is
    // just a ~460KB memcpy, cheap enough to do inline on mCameraHandler.
    private void maybeQueuePreviewFrame() {
        Surface surface = mPreviewSurface;
        final boolean usable = surface != null && surface.isValid();
        if (usable != mLastPreviewSurfaceUsable) {
            Log.i(TAG, "maybeQueuePreviewFrame: surface usability changed to " + usable
                    + " surface=" + surface);
            mLastPreviewSurfaceUsable = usable;
        }
        if (!usable) {
            return;
        }
        mPreviewFrameCounter++;
        if (mPreviewFrameCounter % PREVIEW_FRAME_SKIP != 0) {
            return;
        }
        if (!mPreviewRenderInFlight.compareAndSet(false, true)) {
            return;
        }
        System.arraycopy(mNv21Buffer, 0, mPreviewNv21Buffer, 0, NV21_SIZE);
        mPreviewHandler.post(() -> {
            try {
                renderPreviewFrame();
            } finally {
                mPreviewRenderInFlight.set(false);
            }
        });
    }

    // vivo 1907N Face Unlock bring-up (not AOSP): draws mPreviewNv21Buffer into the live
    // self-view surface, if any (see mPreviewSurface's field comment) - runs on mPreviewHandler,
    // never on mCameraHandler (see maybeQueuePreviewFrame()). Goes through a JPEG round-trip
    // (YuvImage -> BitmapFactory) rather than a hand-rolled YUV->RGB conversion - simpler and
    // reliably correct, and now throttled/off the critical thread the CPU cost is acceptable.
    // Failures here (surface torn down mid-frame by a screen rotation, preview fragment paused,
    // etc.) must never take down frame capture itself, hence the broad catch.
    private void renderPreviewFrame() {
        Surface surface = mPreviewSurface;
        if (surface == null || !surface.isValid()) {
            return;
        }
        try {
            mJpegScratch.reset();
            new YuvImage(mPreviewNv21Buffer, ImageFormat.NV21, CAPTURE_WIDTH, CAPTURE_HEIGHT, null)
                    .compressToJpeg(new Rect(0, 0, CAPTURE_WIDTH, CAPTURE_HEIGHT), 80,
                            mJpegScratch);
            byte[] jpeg = mJpegScratch.toByteArray();
            Bitmap rawFrame = BitmapFactory.decodeByteArray(jpeg, 0, jpeg.length);
            if (rawFrame == null) {
                return;
            }
            // Compensate for the sensor's physical mounting orientation, and mirror
            // horizontally so the preview reads like an actual mirror (a front camera's raw
            // buffer is not pre-mirrored) - see mSensorOrientation's field comment. Assumes the
            // enrollment UI stays in its natural (portrait) orientation throughout, which
            // FaceEnrollEnrolling does in practice.
            Bitmap frame = transformFrame(rawFrame, mSensorOrientation);
            Canvas canvas = surface.lockCanvas(null);
            try {
                drawFrameCovering(canvas, frame);
            } finally {
                surface.unlockCanvasAndPost(canvas);
            }
            rawFrame.recycle();
            frame.recycle();
            // vivo 1907N Face Unlock bring-up (not AOSP): diagnostic heartbeat, every 10th
            // successful render - proves rendering is still actually happening (or silently
            // stopped) without spamming on every frame.
            mRenderedFrameCount++;
            if (mRenderedFrameCount % 10 == 0) {
                Log.i(TAG, "renderPreviewFrame: rendered #" + mRenderedFrameCount);
            }
        } catch (Exception e) {
            // Broad on purpose: Surface.lockCanvas() throws the checked
            // Surface.OutOfResourcesException, and the surface can also be torn down
            // concurrently (screen rotation, preview fragment pausing) - none of that may ever
            // take down frame capture itself.
            Log.w(TAG, "Failed to render preview frame", e);
        }
    }

    /** Rotates {@code src} clockwise by {@code degrees} then mirrors it horizontally (selfie
     *  mirror), producing a new Bitmap - {@code src} itself is left untouched (caller recycles
     *  both). Rotation is applied first so the mirror always flips the *upright* image
     *  left-right, not whatever's left/right before correcting for sensor orientation. */
    private static Bitmap transformFrame(Bitmap src, int degrees) {
        Matrix matrix = new Matrix();
        matrix.postRotate(degrees);
        matrix.postScale(-1, 1);
        return Bitmap.createBitmap(src, 0, 0, src.getWidth(), src.getHeight(), matrix, true);
    }

    /** Scales {@code frame} to fill (cover, center-cropping) {@code canvas} - the preview surface
     *  is a square (FaceSquareTextureView) but the capture resolution generally isn't. */
    private static void drawFrameCovering(Canvas canvas, Bitmap frame) {
        float scale = Math.max(
                (float) canvas.getWidth() / frame.getWidth(),
                (float) canvas.getHeight() / frame.getHeight());
        float drawWidth = frame.getWidth() * scale;
        float drawHeight = frame.getHeight() * scale;
        float left = (canvas.getWidth() - drawWidth) / 2f;
        float top = (canvas.getHeight() - drawHeight) / 2f;
        Rect dst = new Rect(Math.round(left), Math.round(top),
                Math.round(left + drawWidth), Math.round(top + drawHeight));
        canvas.drawBitmap(frame, null, dst, null);
    }

    /** Converts a YUV_420_888 Image into a tightly-packed NV21 byte array (Y, then interleaved
     *  VU at half resolution), respecting each plane's row/pixel stride - Camera2 does NOT
     *  guarantee YUV_420_888 is already tightly packed or NV21-ordered. */
    private static void imageToNv21(Image image, byte[] out) {
        int width = image.getWidth();
        int height = image.getHeight();

        Image.Plane yPlane = image.getPlanes()[0];
        ByteBuffer yBuffer = yPlane.getBuffer();
        int yRowStride = yPlane.getRowStride();
        int pos = 0;
        for (int row = 0; row < height; row++) {
            yBuffer.position(row * yRowStride);
            yBuffer.get(out, pos, width);
            pos += width;
        }

        Image.Plane uPlane = image.getPlanes()[1];
        Image.Plane vPlane = image.getPlanes()[2];
        ByteBuffer uBuffer = uPlane.getBuffer();
        ByteBuffer vBuffer = vPlane.getBuffer();
        int uvRowStride = vPlane.getRowStride();
        int uvPixelStride = vPlane.getPixelStride();
        int chromaWidth = width / 2;
        int chromaHeight = height / 2;
        for (int row = 0; row < chromaHeight; row++) {
            int rowStart = row * uvRowStride;
            for (int col = 0; col < chromaWidth; col++) {
                int uvOffset = rowStart + col * uvPixelStride;
                out[pos++] = vBuffer.get(uvOffset);
                out[pos++] = uBuffer.get(uvOffset);
            }
        }
    }

    private void closeCamera() {
        if (mCaptureSession != null) {
            mCaptureSession.close();
            mCaptureSession = null;
        }
        if (mCameraDevice != null) {
            mCameraDevice.close();
            mCameraDevice = null;
        }
        if (mImageReader != null) {
            mImageReader.close();
            mImageReader = null;
        }
    }

    /** Minimal, low-priority notification purely to satisfy the foreground-service requirement
     *  (see onStartCommand()) - this runs for a few seconds during enroll/authenticate, not
     *  something the user needs to be alerted about beyond it being visible if they pull down
     *  the shade, hence IMPORTANCE_MIN/no sound/no badge. */
    private Notification buildNotification() {
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm.getNotificationChannel(NOTIFICATION_CHANNEL_ID) == null) {
            NotificationChannel channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID,
                    "Face capture", NotificationManager.IMPORTANCE_MIN);
            channel.setShowBadge(false);
            nm.createNotificationChannel(channel);
        }
        return new Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .setContentTitle("Face capture running")
                .setOngoing(true)
                .build();
    }
}
