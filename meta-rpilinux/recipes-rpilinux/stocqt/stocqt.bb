DESCRIPTION = "QT Demo Stock App"

# Don't want to have to download license
LICENSE="CLOSED"

inherit qt6-cmake

W = "${WORKDIR}"

SRCBRANCH ??= "main"
SRC_URI = "\
            git://github.com/Inquisitive-ME/stocqt.git;branch=${SRCBRANCH} \
            file://stocqt.service \
          "

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += "qtdeclarative qtdeclarative-native qtbase qtimageformats qtshadertools qtsvg"

inherit systemd

SYSTEMD_PACKAGES = "stocqt"

SYSTEMD_SERVICE:${PN}   =     "stocqt.service"
FILES:${PN}             =     " ${systemd_system_unitdir}/stocqt.service \
                                ${bindir}, ${bindir}/stocqt, /usr/share/examples/demos/stocqt/stocqt \
                              "

do_install:append(){
    install -d ${D}/${systemd_system_unitdir}
    
    install -m 0644 ${WORKDIR}/stocqt.service ${D}/${systemd_system_unitdir}
}
