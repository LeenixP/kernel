echo "Starting boot.scr script..."

if test -e ${devtype} ${devnum}:${distro_bootpart} /configs/config.txt && test "${dtovcfg_status}" = "okay"; then 

    ext2ls ${devtype} ${devnum}:${distro_bootpart}

    setenv devpart "${devnum}:${distro_bootpart}"
    printenv devpart

    echo "Loading device tree..."
    if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} /rk-kernel.dtb; then
        fdt addr ${fdt_addr_r}
    else
        echo "Error: Failed to load device tree. Aborting."
        exit 1
    fi

    echo "Applying dtoverlay..."
    if dtovcfg ${fdt_addr_r} /configs/config.txt; then
        echo "Applying dtoverlay successfully."
    else
        echo "Error: Failed to apply dtoverlay. Aborting."
        exit 1
    fi

    setenv bootargs "${bootargs} root=/dev/mmcblk${devnum}p3 ${cmdline}"
    fdt set /chosen bootargs
    printenv bootargs  
    
    echo "Loading  kernel image..."
    if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} /Image-${kernel_version}; then
        echo "Kernel image loaded successfully."
    else
        echo "Error: Failed to load kernel image. Aborting."
        exit 1
    fi

    rgbctrl r off
    rgbctrl g off
    rgbctrl b off

    echo "Booting kernel..."
    booti ${kernel_addr_r} - ${fdt_addr_r}
fi
echo "Failed to execute boot.scr script. Attempting extlinux..."
