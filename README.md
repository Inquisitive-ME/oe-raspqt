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

## Change Machine Type
```
MACHINE ??= "raspberrypi4-64"
``` 

## Set AUTHORIZED_KEYS_FILE_PATH
```
AUTHORIZED_KEYS_FILE_PATH="<path_to_authorized_keys>"
```
authorized_keys should be a file containing the public key you wish to use to access the rasperry pi

## To get an image
```
IMAGE_FSTYPES = "rpi-sdimg"
```
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
```

# Build
Run

```
bitbake rpilinux-image
```

# Output
`/tmp/deploy/images/raspberrypi4-64/rpilinux-image-raspberrypi4-64.rootfs.rpi-sdimg`
Can be flashed to sd card using
```
sudo dd if=rpilinux-image-raspberrypi4-64-20220406135939.rootfs.rpi-sdimg of=/dev/sdb bs=8192 status=progress
```
where `/dev/sdb` is the location of the sd card

# Current Status
* Image boots
* login is root
* basic additions work (python numpy)
* image size 316 MB

# References
Started with [Hacking Raspberry Pi 4 with Yocto](https://lancesimms.com/RaspberryPi/HackingRaspberryPi4WithYocto_Introduction.html)

[Poky](https://git.yoctoproject.org/poky)

# TODO
* Figure out how to have `bblayers.conf` automatically include the required layers
```
  meta-raspberrypi
  meta-rpilinux
  meta-openembedded/meta-oe
  meta-openembedded/meta-python
```

* Figure out mDNS or a method to broadcast / know IP Address

* Add ability to compile and run QT applications