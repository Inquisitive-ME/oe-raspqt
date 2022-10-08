SUMMARY = "Recipe to add to config.txt"

BOOTFILES_DIR = "bootfiles"

RPI_EXTRA_CONFIG = ' \n \
    max_framebuffers=2 \n \
    kernel=kernel_rpilinux.img \n \
    arm_64bit=1 \n \
    disable_splash=1 \n \
    disable_overscan=1 \n \
    arm_boost=1 \n \
    gpu_mem=512 \n \
    '
