require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL += "glibc libstdc++ bash-completion"
IMAGE_INSTALL += "openssh openssl openssh-sftp-server ssh-pregen-hostkeys"
IMAGE_INSTALL += "git"
IMAGE_INSTALL += "udev-extraconf updater"
IMAGE_INSTALL += "python3 python3-numpy python3-pyzmq"

IMAGE_INSTALL += "ttf-liberation-sans-narrow \
                  ttf-liberation-mono \
                  ttf-liberation-sans \
                  ttf-liberation-serif \
                  ttf-roboto \
                  "

IMAGE_INSTALL += "stocqt"

IMAGE_INSTALL += "util-linux"

WKS_FILE = "rpilinux-partitions.wks"

CORE_IMAGE_EXTRA_INSTALL += " \
        ${MACHINE_EXTRA_RRECOMMENDS} \
        "
DISTRO_EXTRA_RDEPENDS += "${MACHINE_EXTRA_INSTALL} \
"

# https://community.toradex.com/t/how-to-remove-getty-tty1-link-in-yocto-dunfell-branch/13134/5
# add the rootfs version to the welcome banner
ROOTFS_POSTPROCESS_COMMAND += "add_rootfs_version; "
ROOTFS_POSTPROCESS_COMMAND += "remove_tty1_service; "

# remove getty@tty1.service and getty@.service
remove_tty1_service () {
    rm -f ${IMAGE_ROOTFS}/lib/systemd/system/getty@.service
    rm -f ${IMAGE_ROOTFS}/etc/systemd/system/getty.target.wants/getty@tty1.service
}

add_rootfs_version () {
    printf "${DISTRO_NAME} ${DISTRO_VERSION} (${DISTRO_CODENAME}) \\\n \\\l\n" > ${IMAGE_ROOTFS}/etc/issue
    printf "${DISTRO_NAME} ${DISTRO_VERSION} (${DISTRO_CODENAME}) %%h\n" > ${IMAGE_ROOTFS}/etc/issue.net
    printf "${IMAGE_NAME}\n\n" >> ${IMAGE_ROOTFS}/etc/issue
    printf "${IMAGE_NAME}\n\n" >> ${IMAGE_ROOTFS}/etc/issue.net
}