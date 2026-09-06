/*
 * vivo 1907N Face Unlock bring-up, Фаза 3 (not AOSP).
 *
 * A raw mmap(2) via JNI. Needed because the shared-memory fd FaceManager.getShareMemoryFd()
 * hands us (backed by ashmem, see Face10.java's scheduleGetShareMemoryFd()) only supports
 * mmap()/ioctl() at the kernel driver level - not read()/write() (confirmed on-device:
 * Os.pwrite() failed with EINVAL on every call), and not ftruncate() either (confirmed
 * on-device: java.nio.FileChannel.map() internally fstat()s the fd, sees size 0 - ashmem's real
 * size lives behind ASHMEM_GET_SIZE, not st_size - and tries to ftruncate() it to match, which
 * ashmem also rejects with EINVAL). android.os.SharedMemory itself works around this by calling
 * Os.mmap() and wrapping the returned address in a java.nio.DirectByteBuffer via a
 * package-private constructor - a core-platform-api symbol not accessible to a regular app even
 * when platform-signed (a stricter boundary than ordinary framework @hide/@SystemApi). JNI's
 * NewDirectByteBuffer() is the one way to get the same result (a real address-backed
 * ByteBuffer) from ordinary app code: it's part of the JNI specification itself, not subject to
 * any Android hidden-API allowlist.
 */

#include <jni.h>
#include <sys/mman.h>

JNIEXPORT jobject JNICALL
Java_com_android_facecapture_FaceCaptureService_nativeMmap(JNIEnv *env, jclass clazz,
                                                             jint fd, jint size) {
    void *addr = mmap(NULL, (size_t) size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr == MAP_FAILED) {
        return NULL;
    }
    return (*env)->NewDirectByteBuffer(env, addr, size);
}

JNIEXPORT void JNICALL
Java_com_android_facecapture_FaceCaptureService_nativeMunmap(JNIEnv *env, jclass clazz,
                                                               jobject buffer, jint size) {
    void *addr = (*env)->GetDirectBufferAddress(env, buffer);
    if (addr != NULL) {
        munmap(addr, (size_t) size);
    }
}
