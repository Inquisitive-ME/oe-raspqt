require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL += "glibc libstdc++"
IMAGE_INSTALL += "openssh openssl openssh-sftp-server ssh-pregen-hostkeys"
IMAGE_INSTALL += "git"
IMAGE_INSTALL += "python3 python3-numpy stocqt"
IMAGE_INSTALL += "ttf-liberation-sans-narrow \
                ttf-liberation-mono \
                ttf-liberation-sans \
                ttf-liberation-serif \
                "

CORE_IMAGE_EXTRA_INSTALL += " \
        ${MACHINE_EXTRA_RRECOMMENDS} \
        "
DISTRO_EXTRA_RDEPENDS += "${MACHINE_EXTRA_INSTALL} \
"