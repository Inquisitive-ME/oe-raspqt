SUMMARY = "Recipe to add to config.txt"

BOOTFILES_DIR = "bootfiles"

RPI_EXTRA_CONFIG = ' \n \
    max_framebuffers=2 \n \
    kernel=kernel_rpilinux.img \n \
    arm_64bit=1 \n \
    disable_splash=1 \n \
    arm_freq=900 \n \
    core_freq=33 \n \
    sdram_freq=450 \n \
    over_voltage=2 \n \
    gpu_mem=128 \n \
    '
