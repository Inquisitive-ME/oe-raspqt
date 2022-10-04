#!/bin/sh

HOME="/home/root"
WORKING_DIR="/home/share/update"
USBPATH=$(find /run/media/ -type d -name "*sda2*")
URL="http://192.168.1.1:8000"
HASHFILE="update.sha256"

echo "USB PATH: ${USBPATH}"
echo "WORKING DIR: ${WORKING_DIR}"
echo "HOME: ${HOME}"

finish() {
	rm -f ${WORKING_DIR}/${HASHFILE}.pending
}

trap finish EXIT

no_update() {
	echo "No update available"
	exit 0
}

exit_error() {
	echo "$1"
	exit 1
}

mkdir -p "$WORKING_DIR"

# Fetch the update hash and use to determine if an update is needed
if [ "$1" = "--usb" ]; then
	echo "Running in USB mode"
	if [ ! -f "${USBPATH}/${HASHFILE}" ]; then
		echo "Could not find ${USBPATH}/${HASHFILE} try sleeping"
		sleep 1
	fi
	cp "${USBPATH}/${HASHFILE}" "${WORKING_DIR}/${HASHFILE}.pending" || no_update
	UPDATE_LOC="${USBPATH}"
	if grep -q .raucb "${WORKING_DIR}/${HASHFILE}.pending"; then
		echo "remount ${UPDATE_LOC} with correct permissions"
		umount ${UPDATE_LOC}
		mount /dev/sda2 ${UPDATE_LOC} -o umask=07777
	fi
else
	wget -q "${URL}/${HASHFILE}" -O "${WORKING_DIR}/${HASHFILE}.pending" >/dev/null 2>&1  || no_update
	if ! cmp -s "${WORKING_DIR}/${HASHFILE}" "${WORKING_DIR}/${HASHFILE}.pending"; then
		wget "${URL}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)" -O "${WORKING_DIR}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)"
		UPDATE_LOC="${WORKING_DIR}"
	else
		no_update
	fi
fi

if ! cmp -s "${WORKING_DIR}/${HASHFILE}" "${WORKING_DIR}/${HASHFILE}.pending"; then
	echo "New Update: Updating"	
	if grep -q .raucb "${WORKING_DIR}/${HASHFILE}.pending"; then
		echo "rauc update"
		rauc install "${UPDATE_LOC}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)" || exit_error "failed to install update"
	else
		echo "not rauc update try to unzip to ${HOME}"
		tar xf "${UPDATE_LOC}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)" -C ${HOME} || exit_error "failed to download update"
	fi
	echo "${WORKING_DIR}/${HASHFILE}.pending >> ${WORKING_DIR}/${HASHFILE}"
	mv "${WORKING_DIR}/${HASHFILE}.pending" "${WORKING_DIR}/${HASHFILE}"
	echo "Update complete, rebooting"
	sync
	sleep 1
	reboot
else
	no_update
fi

