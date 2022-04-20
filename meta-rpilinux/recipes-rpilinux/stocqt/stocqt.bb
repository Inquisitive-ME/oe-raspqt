DESCRIPTION = "QT Demo Stock App"

# Don't want to have to download license
LICENSE="CLOSED"

inherit qt6-cmake

W = "${WORKDIR}"

SRCBRANCH ??= "main"
SRC_URI = "git://github.com/Inquisitive-ME/stocqt.git;branch=${SRCBRANCH}"

SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += "qtdeclarative qtdeclarative-native qtbase qtimageformats qtshadertools qtsvg"

FILES:${PN} = " ${bindir}, ${bindir}/stocqt, /usr/share/examples/demos/stocqt/stocqt"

# do_install:append(){
# 	install -d ${D}${bindir}
# }

