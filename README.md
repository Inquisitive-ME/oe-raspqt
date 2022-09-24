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
MACHINE ??= "raspberrypi4-64"
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
I could not get either working so my plan was to just have a second partition with some manual method of being able to perform updates using the second partition

Currently that partition is not automounting for some reason

But when it is mounted I am able to put a new rootfs onto the partition by:
`tar xf rpilinux-image-raspberrypi4-64.tar.bz2 -C /mnt/rootB/`

And then can change the cmdline.txt to use `root=/dev/mmcblk0p3` and boot an updated rootfs

My other thought was to just put applications I would want to updated into this partition but I'm not sure if Yocto supports installing into another partition


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
* Add method for updates via usb or network instead of having to flash an sd card and replace the existing one
