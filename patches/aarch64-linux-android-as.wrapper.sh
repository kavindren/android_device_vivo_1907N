#!/bin/sh
# Wrapper: the real bundled 4.9-era GNU as (aarch64-linux-android-as.real, kept alongside)
# can't parse clang-14's newer assembly syntax ("junk at end of line" on .file/.loc
# directives). clang's -no-integrated-as path resolves this exact filename via its own
# --prefix/--gcc-toolchain logic (not via the AS= make variable), so replacing the binary
# in place - rather than trying to redirect AS= - is what actually takes effect. Delegates
# to a modern aarch64-linux-gnu-as (pacman: extra/aarch64-linux-gnu-binutils).
exec /usr/bin/aarch64-linux-gnu-as "$@"
