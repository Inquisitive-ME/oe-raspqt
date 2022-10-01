# oe-raspqt
Minimal image required to boot to QT application on Raspberry Pi

# Getting Started
## Clone all Submodules
```
git submodule update --init --recursive
```

## Navigate to poky
````
cd poky
````

## Source Env
````
source oe-init-build-env
````

## Set Local Conf

### Change Machine Type
```
MACHINE ?= "raspberrypi4-64"
``` 

### Set AUTHORIZED_KEYS_FILE_PATH
```
AUTHORIZED_KEYS_FILE_PATH="<path_to_authorized_keys>"
```
authorized_keys should be a file containing the public key you wish to use to access the rasperry pi

### Optional: Set number of threads for bitbake and make
```
BB_NUMBER_THREADS = "16"
PARALLEL_MAKE = "-j 16"
```

## Add Layers to build/conf/bblayers.conf
```
  meta-raspberrypi
  meta-rpilinux
  meta-openembedded/meta-oe
  meta-openembedded/meta-python
  meta-qt6
```

# Build
Run

```
bitbake rpilinux-image
```

# Output
`/tmp/deploy/images/raspberrypi4-64/rpilinux-image-raspberrypi4-64.wic.bz2`
Can be flashed to sd card using
```
sudo bmaptool copy rpilinux-image-raspberrypi4-64.wic.bz2 /dev/sdb
```
where `/dev/sdb` is the location of the sd card

`bmaptool` can be installed on Ubuntu via apt:
`sudo apt install bmap-tools`

[flashing reference](https://github.com/agherzan/meta-raspberrypi/issues/637)

# Current Status
* Image boots
* login is root
* basic additions work (python numpy)
* image size 316 MB

## QT
* Can build QT application but can't render
* test application is `/usr/share/examples/demos/stocqt/stocqt`

# References
Started with [Hacking Raspberry Pi 4 with Yocto](https://lancesimms.com/RaspberryPi/HackingRaspberryPi4WithYocto_Introduction.html)

[Poky](https://git.yoctoproject.org/poky)

# Work in Progress
## Console Rendering Issues
I have had some issues with the console rendering ontop of the QT application
To fix this I have disabled the `getty@tty1.service` you can still ssh into the machine and loging to a console
but in order to login via the screen I think you would need to renable this. This is in the `rpilinux-image.bb` recipe `ROOTFS_POSTPROCESS_COMMAND += "remove_tty1_service; "`
 
## Dual Partition Updates
I attempted to add either rouc or mender to try to have 2 partitions and be able to update via usb or network
I could not get either working so I just have a second partition created using wic with the `rpilinux-partitions.wks` file.

I then have a very hacky script that is run as a service to update either a full rootfs or just contents of a zip file to the other partition. The way it works:
1. Create a USB drive with 2 partitions second partition must be labeled "UPDATE"
2. Copy zipped version of contents onto the USB drive you wish to have copied to the second partition
3. The update script looks for a `update.sha256` file to check weather there is a new update
4. You can run `sha256sum <zip_file_name> > update.sha256` to create the file
5. In order to boot to a new rootfs the script looks for `.rootfs.tar` to be in the zip file name otherwise it will not switch the rootfs and will just copy the contents to the second partition
6. Example of creating sha file for rootfs. `sha256sum rpilinux-image-raspberrypi4-64-20220925185212.rootfs.tar.bz2 > update.sha256` where `rpilinux-image-raspberrypi4-64-20220925185212.rootfs.tar.bz2` is the new rootfs you wish to switch to

The network update can be done by having both of these files (`rpilinux-image-raspberrypi4-64-20220925185212.rootfs.tar.bz2` and `update.sha256`) in a folder on a computer then running `python3 -m http.server` from within that folder and updating `/usr/bin/updater.sh` to use the IP of the computer running the server.

The updater only checks if the `update.sha256` file is different than the last one. There is currently no check on the sha sum or on the date of the files.

The network service is `net-updater.service` and the usb update service is `updater.service` they both use the `/usr/bin/updater.sh` script

### Notes
The automounting of the USB's could be improved currently it uses the label so in order for the update to work when a drive is plugged in the drive needs to have a second partition with the label "UPDATE"
Specifically `run-media-DATA\x2dsda1.mount` is used to trigger the update script

The update basically does:
`tar xf rpilinux-image-raspberrypi4-64.tar.bz2 -C /run/media/rootB-mmcblk0p3/`
or
`tar xf rpilinux-image-raspberrypi4-64.tar.bz2 -C /run/media/rootA-mmcblk0p2/`

It does check that the compressed update file contains `.rootfs.tar` in an attempt to not switch to an unbootable partition. But there are no sanity checks that the partition will boot before it switches

The boot partition is changed by changing the cmdline.txt to use either `root=/dev/mmcblk0p3` or `root=/dev/mmcblk0p2` whichever is not the current rootfs

In order to try to perserve some files across updates the home partition is coppied. There is also an option to update the `updater.sh` to add a settings directory that applications maybe saving files to you want to have copied over.

This is not a very good way to perform updates, and I would like to get mender or rouc working as the long term solution but had several problems when trying to use either.

The other option with this method if you are mainly updating a single application is to zip the application and install just the application to the second partition then sym link it to `/usr/bin/` I have tried this and had some issues with execution permissions with the applciation so to get around it I just add `ExecStartPre=chmod +x <app_name>` in the service file.

# TODO
* Figure out how to have `bblayers.conf` automatically include the required layers
```
  meta-raspberrypi
  meta-rpilinux
  meta-openembedded/meta-oe
  meta-openembedded/meta-python
  meta-qt6
```

* Figure out mDNS or a method to broadcast / know IP Address
* Figure out rouc or mender for better updates via usb or network instead of just writing some zip file to the other partition with no checks
