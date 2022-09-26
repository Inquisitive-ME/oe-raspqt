#!/bin/sh

HOME="/home/root"
WORKING_DIR="/usr/share/update"
USBPATH=$(find /run/media/ -type d -name "*sda2*")
URL="http://192.168.1.1:8000"
HASHFILE="update.sha256"
CURRENT_ROOT=$(cat /proc/cmdline | grep -o '/dev/mmcblk0p3\|/dev/mmcblk0p2')
NEW_ROOT=$(lsblk | sed -n 's#.*\(/run/media/root.*mmcblk0p[0-9]\).*#\1#p')
SETTINGS_PATH="/.config"

echo "CURRENT ROOT: ${CURRENT_ROOT}"
echo "NEW ROOT: ${NEW_ROOT}"
echo "USB PATH: ${USBPATH}"
echo "WORKING DIR: ${WORKING_DIR}"
echo "HOME: ${HOME}"

finish() {
	rm -f "${WORKING_DIR}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)"
	rm -f ${WORKING_DIR}/${HASHFILE}.pending
	rm -f changelog.txt
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
	cp "${USBPATH}/${HASHFILE}" "${WORKING_DIR}/${HASHFILE}.pending" || no_update
	UPDATE_LOC="${USBPATH}"

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
	echo "Remove ${NEW_ROOT}/*"
	rm -rf "${NEW_ROOT}/*":
	echo "Un-Compress and copy ${UPDATE_LOC}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)"
	tar xf "${UPDATE_LOC}/$(awk '{print $2}' ${WORKING_DIR}/${HASHFILE}.pending)" -C ${NEW_ROOT} || exit_error "failed to download update"
	if grep -q .rootfs.tar. "${WORKING_DIR}/${HASHFILE}.pending"; then
		sed -i "s#root=/dev/mmcblk0p2#root=/dev/mmcblk0p3#w changelog.txt" "/boot/cmdline.txt"
		if [ -s changelog.txt ]; then
			# on mmcblk0p2 changed to mmcblk0p3
			echo "Change boot to mmcblk0p3"
			:
		else
			# on mmcblk0p3 need to change to mmcblk0p2
			sed -i "s#root=/dev/mmcblk0p3#root=/dev/mmcblk0p2#w changelog.txt" "/boot/cmdline.txt"
			echo "Change boot to mmcblk0p2"
		fi
		rm -rf changelog.txt
		echo "Changing to New rootfs"
		mkdir -p "${NEW_ROOT}/${WORKING_DIR}"
		echo "Move ${WORKING_DIR}/${HASHFILE}.pending >> ${NEW_ROOT}/${WORKING_DIR}/${HASHFILE}"
		mv "${WORKING_DIR}/${HASHFILE}.pending" "${NEW_ROOT}/${WORKING_DIR}/${HASHFILE}"
		echo "Copy ${HOME} >> ${NEW_ROOT}/${HOME}"
		cp -a "${HOME}/." "${NEW_ROOT}/${HOME}/"
		echo "Copy ${SETTINGS_PATH} >> ${NEW_ROOT}/${SETTINGS_PATH}"
		mkdir -p "${NEW_ROOT}/${SETTINGS_PATH}"
		cp -a "${SETTINGS_PATH}/." "${NEW_ROOT}${SETTINGS_PATH}/"
	else
		echo "${WORKING_DIR}/${HASHFILE}.pending >> ${WORKING_DIR}/${HASHFILE}"
		mv "${WORKING_DIR}/${HASHFILE}.pending" "${WORKING_DIR}/${HASHFILE}"
		echo "Not a rootfs update, keeping same boot partition"
	fi
	echo "Update complete, rebooting"
	sync
	sleep 1
	reboot
else
	no_update
fi

