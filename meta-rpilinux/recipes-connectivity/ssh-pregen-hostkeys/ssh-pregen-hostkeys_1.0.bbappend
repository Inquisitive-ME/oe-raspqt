FILESEXTRAPATHS:prepend := "${THISDIR}:" 

SRC_URI += "file://${AUTHORIZED_KEYS_FILE_PATH}"
do_install:append() {
    install ${AUTHORIZED_KEYS_FILE_PATH} ${D}${sysconfdir}/ssh/
}
