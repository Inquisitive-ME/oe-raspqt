FILESEXTRAPATHS:prepend := "${THISDIR}:" 
do_install:append () {
   install -d ${D}/mnt/rootB
}
