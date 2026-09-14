# Parked: MtkTelephonyComponentFactory / MtkRIL injection

**Status as of 2026-09-14: reverted to plain AOSP telephony.** `com.android.phone` was crash-looping
on every boot with `java.lang.NoClassDefFoundError: Class not found using the boot class loader; no
stack trace available` — a genuinely missing/unresolvable class reference somewhere in the boot
classpath chain (confirmed via ART source reading that this specific message means "class not found",
not "class failed verification" — see the investigation notes below). Root cause was never found
despite extensive diagnosis (5+ build/flash cycles, all producing the identical crash; local `dex2oat
--compiler-filter=verify` runs against all 8 touched MTK/vivo boot jars came back completely clean, 0
errors). Basic connectivity (calls/SMS/data) was down the entire time this was active, since
`com.android.phone` never survived long enough to register on the network.

Decision: park this whole effort rather than keep guessing blind. These two patches are **not
applied** anymore (removed from `patches/BASE` and both arrays in `apply-patches.sh`) — the device
now runs completely stock AOSP `RIL`/`TelephonyComponentFactory`, same as before this effort started.

## What's here

- `frameworks_opt_telephony_mtkril.patch` — the full `frameworks/opt/telephony` diff: `MtkRIL`
  reflection swap-in (`PhoneFactory.newRil()`), `MtkTelephonyComponentFactory` injection
  (`TelephonyComponentFactory.getInstance()`), and every downstream visibility/compat fix this
  required across `ServiceStateTracker`, `SubscriptionController`, `SmsStorageMonitor`, `ImsPhone`,
  `ImsPhoneCallTracker`, `TransportManager`, `TelephonyDevController`, `RIL`, `RadioIndication`,
  `BaseCommands`.
- `frameworks_base_mtkservicestate_fix.patch` — the `frameworks/base` diff: `ServiceState.java`
  visibility widening (21 members) for `mediatek.telephony.MtkServiceState`, plus the
  `api_lint.baseline_file` mechanism in `StubLibraries.bp` + `core/api/lint-baseline.txt` needed to
  get it past metalava.

To reapply either one: `git -C frameworks/opt/telephony apply device/vivo/1907N/patches/parked/frameworks_opt_telephony_mtkril.patch`
(same pattern for the base one, from `frameworks/base`), then re-add both entries to `patches/BASE`
and both arrays in `apply-patches.sh` (see git history around commit `4de6bca`/`bd2u...` for the
exact array entries that were removed).

## Where the investigation got to (context for resuming)

- `MtkRIL` construction itself was rock-solid throughout - `ril.mtkril.instance0/1` always showed
  `com.mediatek.internal.telephony.MtkRIL`, never regressed by anything in this whole effort.
- `MtkTelephonyComponentFactory` injection got through construction of `SubscriptionController` →
  `SmsStorageMonitor` → `ServiceStateTracker` (105+ widened members) → `TransportManager` (relocated
  methods) → signal strength/CellLocation (relocated/removed fields) → `MtkServiceState`
  (`frameworks/base`, 21 widened members + api-lint baseline) — each of those was a genuine, confirmed
  fix (crash moved forward every time) until it stalled on the generic `NoClassDefFoundError`.
- That final crash survived FIVE different specific fixes to `ServiceState.setFromNotifierBundle`
  alone (visibility, dropped `@hide`, real `@Nullable`/`@NonNull`, moving a comment out of the javadoc
  block that was accidentally re-triggering metalava's hide detection, and finally replacing all
  `@SuppressLint` with the api_lint baseline mechanism) - every one of these individually verified
  correct (confirmed via `dexdump` of the real on-device `framework.jar`) but none changed the crash.
- Read `art/runtime/runtime.cc`/`class_linker.cc`/`hidden_api.cc` directly:
  - The hiddenapi-domain-blocking theory (from partway through this) is **wrong** -
    `mediatek-telephony-base.jar` and `framework.jar` are both `/system/framework/*.jar`, so ART's
    `DetermineDomainFromLocation()` gives them the same `Domain::kPlatform`, and
    `CanAlwaysAccess()` short-circuits same-domain callers before any per-member flag is even
    checked.
  - The exact crash message ("Class not found using the boot class loader; no stack trace
    available") comes from ONE hardcoded pre-allocated exception (`runtime.cc` ~line 1946), used at
    several call sites in `class_linker.cc`. The most relevant one (`FindClass()`, ~line 2900) is
    explicitly for the ordinary "class genuinely not found via the boot classloader" case, NOT a
    cached verification failure - i.e. this is likely a literal missing/unresolvable class
    reference somewhere, not a verifier rejection.
  - Ran `dex2oat --compiler-filter=verify` locally (bypassing the ~27min full build) against all 8
    touched MTK/vivo boot jars (`mediatek-telephony-base`, `mediatek-telephony-common`,
    `vivo-telephony-common`, `mediatek-common`, `mediatek-framework`, `mediatek-ims-common`,
    `mediatek-ims-base`, `mediatek-telecom-common`) with the patched `framework.jar` on the
    classpath - all came back 100% clean (`Verified`/`VerifiedNeedsAccessChecks`, zero errors). This
    strongly suggests the classes we touched are NOT the actual problem, but this was never fully
    confirmed against the *real* chained boot-image-extension compilation (only a flat
    `-Xbootclasspath` + imageless reproduction, which may not perfectly replicate the on-device
    compile - attempting a faithful `--boot-image=` extension repro hit an image-component-count
    mismatch and wasn't resolved before the decision to park this).

## Natural next steps, if/when this gets picked back up

1. Reapply both patches, confirm the crash reproduces exactly as before.
2. Do a real bisection: comment out `MtkTelephonyComponentFactory` injection (revert just
   `TelephonyComponentFactory.getInstance()`) while keeping `MtkRIL` alone - `MtkRIL` alone was
   stable for a long time before this segment, so this isolates whether the base jar
   (`mediatek-telephony-base.jar`/`ServiceState`) integration is really the culprit, or whether it's
   something in `mediatek-telephony-common.jar`'s much larger surface instead.
2. Alternatively, properly replicate the chained boot-image-extension `dex2oat` invocation (with a
   real profile for the primary `boot-framework.art`, then `--boot-image=` chaining each extension in
   the real order) to see if that reveals what the flat/imageless reproduction couldn't.
3. Consider whether the `mediatek-ims-common`/`mediatek-ims-base`/`mediatek-telecom-common`/
   `mediatek-common`/`mediatek-framework` jars have their OWN inherited-access violations against
   current AOSP that were never audited via the smali-diff method (only reactively touched when they
   crashed) - since construction never got far enough to exercise most of their code paths.
