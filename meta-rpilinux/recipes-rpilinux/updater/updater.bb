LICENSE = "CLOSED"

inherit systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN}  = "updater.service"
SYSTEMD_SERVICE:${PN} += "net-updater.service"

SRC_URI:append = "file://updater.sh \
           	  file://updater.service \
           	  file://net-updater.service \
"

FILES:${PN} += "${systemd_system_unitdir}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/updater.sh ${D}${bindir}

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/updater.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/net-updater.service ${D}${systemd_system_unitdir}
}

