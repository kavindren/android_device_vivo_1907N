$(DTB_OUT):
	mkdir -p $(DTB_OUT)

$(INSTALLED_DTBIMAGE_TARGET): $(DTC) $(DTB_OUT)
	@echo "Building dtb.img (vivo 1907N: wrap.py MTK LK header over mt6768.dtb)"
	$(hide) find $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts -type f -name "*.dtb" | xargs rm -f
	$(call make-dtb-target,$(KERNEL_DEFCONFIG))
	$(call make-dtb-target,$(TARGET_KERNEL_DTB))
	$(hide) python3 $(TARGET_KERNEL_SOURCE)/wrap.py \
		$(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/mediatek/mt6768.dtb $@
	$(hide) touch -c $(DTB_OUT)
