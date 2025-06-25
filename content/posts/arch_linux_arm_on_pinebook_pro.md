---
title: Installing Arch Linux ARM on a Pinebook Pro
date: "2025-06-02T14:41:20+00:00"
draft: false
---

A series of notes for future me,
regarding the installation of Arch Linux ARM on a Pinebook Pro.

----

First,
installing a new OS.

I'm sure we're all familiar with the process:
 * `fdisk` an MBR partition table with two partitions;
   the first should be 512M wide.
   I know,
   old advice was ~200M,
   but compression has fallen out of fashion in the last few years.
   As always,
   the first should be W95 FAT32.
 * `mkfs.vfat` and `mkfs.ext4` respectively.
   Don't forget you need to install `dosfstools` for the former!
 * Mount the partitions as local folders `root/` and `boot/` respectively.
 * `bsdtar` the latest Arm Linux ARM image into `root/`,
   then `mv root/boot/* boot/`.

From here you'd normally `genfstab`, `arch-chroot`, `pacstrap`, etc.
But since you're almost certainly creating an ARM installation on an AMD64 host,
that's not going to work very well.

Next best things:
 * `wget` any mission critical packages and put them in `root/var/`,
   so you can `pacman -U` them offline.
 * Have an ethernet USB dongle handy.
   (More on this later.)
 * Get UUIDs from `blkid` and update `root/etc/fstab`.
   Don't worry about the boot options,
   just use `defaults`.

----

***But...***
There's some things about the Pinebook Pro...

The boot order is hardcoded:
 1. SPI flash
 2. eMMC
 3. SD Card
 4. USB

Many guides include details for installing to NVME,
which is possible,
except that the NVME isn't bootable.

Also you [can't actually boot by USB](https://forum.pine64.org/showthread.php?tid=14232).
As in,
it's been plainly advertised all along that you cannot boot by USB-C,
but you *can't really* do it by USB-B either.

I didn't realize this until I decided that I *wanted* to re-install:
the boot loader I have on the SPI flash doesn't support selecting a boot device!
What a silly oversight.
That means I have to flash a new boot loader before I can do anything *but* boot from removable drives.

*Then* I can boot from a removable SD card and use that installation to install Arch again on the eMMC.

In summary,
what you need to do is:
 1. Power down.
 2. Open up the chassis.
 3. Flip the hardware switch disabling power to the eMMC module.
    It's a little push toggle on the motherboard next to the battery.
    There's a white outline on the motherboard below indicating the 'on' position.
 4. Verify that the eMMC isn't bootable by powering on.
    Nothing should happen,
    the power LED should remain orangish-red.
    Power off.
 5. `dd` a boot loader installer to an SD card.
    Currently Tow-Boot is recommended,
    but way back when,
    U-Boot was preferred.
    *See above for how that turned out.*
    For Tow-Boot,
    and for the SPI flash destination specifically,
    the image is named `spi.installer.img`.
 6. Insert that SD card and power on.
    Boot that installer and flash a new boot loader to the SPI flash.
    It's a graphical interface,
    just follow instructions dummy.
    Power off and remove the SD card.
 7. Verify the boot loader installation by powering on.
    Nothing should happen again,
    but the boot loader should have looked different!
    Unless you were already running an up-to-date boot loader.
 8. Power off again and open the chassis back up,
    it's time to re-enable the eMMC module.
    Then close it back up.
 9. Install Arch on an SD card.
    Probably on the same card as before,
    since you don't need to keep a boot loader installer laying around.
 10. Insert that SD card and power on.
     Open the boot menu by pressing ESC;
     select the SD option.
 11. Install Arch on eMMC.

And one last note:
you need to create a file at `boot/extlinux/extlinux.conf` that looks like the below.

```
DEFAULT arch
MENU TITLE Boot Menu
PROMPT 0
TIMEOUT 50

LABEL arch
MENU LABEL Arch Linux ARM
LINUX /Image
INITRD /initramfs-linux.img
FDT /dtbs/rockchip/rk3399-pinebook-pro.dtb
APPEND root=UUID=c1ec9712-5c64-46da-852c-9d665416e8a6 rw

LABEL arch-fallback
MENU LABEL Arch Linux ARM with fallback initramfs
LINUX /Image
INITRD /initramfs-linux-fallback.img
FDT /dtbs/rockchip/rk3399-pinebook-pro.dtb
APPEND root=UUID=c1ec9712-5c64-46da-852c-9d665416e8a6 rw
```

That UUID should match the partition mounted as `/`,
by the way.

You'll see some guides talk about `cmdline` or `cmdline.txt`;
don't do that.
Another thing that fell out of style.
That `APPEND` directive *is* appending to the Linux boot cmdline,
so really this is just another layer of abstraction.

After doing it twice,
you should be fully comfortable with the process.

*(Now that I think about it,
I actually should have been able to use `arch-chroot` for the second installation...
something to think about for the future.)*

As a note:
 * The removable SD card should be exposed at `/dev/mmcblk1`.
 * The eMMC module is `/dev/mmcblk2`.
 * You'll also see some devices like `/dev/mmcblk2boot0` under `lsblk`.
   I *think* these are the SPI flash.
   Not really sure.
   You don't want to touch these anyway.

----

From here,
there's not too much that differs from a normal Arch installation.

Change default users and passwords,
`locale-gen`,
`localectl`,
`timedatectl`,
etc.

I recently
[found](https://www.reddit.com/r/archlinux/comments/rm3kch/comment/hpkr35a/)
a great tip: `sudo pacman -S $(pacman -Ssq noto-fonts)`.

Since this is Arch Linux **ARM**,
don't forget to `pacman-key --populate archlinuxarm` after `pacman-key --init`.

Depending on the model of Pinebook Pro you may need to set the ISO keymap.
That's as easy as `localctl set-keymap uk`.

Install `pipewire`, `pipewire-jack`, `pipewire-pulseaudio`, `wireplumber`, `pavucontrol`, ...
it all works right out of the box.

Then we get to the networking stack...
I noted it above,
and I'll reiterate it here,
*you're likely going to need an ethernet USB dongle*.
Because the networking stack for Pinebook Pro is *ass*.

If you're lucky,
the drivers will work out the box.
You'll know because `wlan0` shows up for `ip link`.
If you're unlucky...
 * Install `base-devel`.
 * Grab [these files](https://gitlab.manjaro.org/manjaro-arm/packages/community/ap6256-firmware/-/tree/master).
 * `makepkg -si`.
 * Good luck.
 * Did that work?
 * Actually just see what *is* in `/lib/firmware/brcm/`.
   If you find a file on the internet that seems like it *could* be in that folder but *isn't*,
   go ahead and install that file.
 * Try [these](https://gitlab.com/kalilinux/build-scripts/kali-arm/-/tree/main/bsp/firmware/pbp)?
 * Good luck?

Don't bother fighting with `systemd-networkd`.
You're already fighting an uphill battle against hardware.
Just give in,
and plan to use `iwctl`.
If you're unfamiliar with this new age tool (like me),
try:

```
$ iwctl
[iwd]# device list
[iwd]# station DEVICE scan
[iwd]# station DEVICE get-networks
[iwd]# station DEVICE connect SSID
```

And when you make a mistake,
rinse and repeat with:

```
[iwd]# known-networks SSID forget
```

Disable IPv6 by creating `/etc/iwd/main.conf` with:

```
[Network]
EnableIPv6=false
```

You can also get away without installing `dhcpcd` by using a built-in client.
Your mileage may vary.
To that same file, add:

```
[General]
EnableNetworkConfiguration=true
```

----

Install `xfce4` and `xfce4-goodies`,
run `startxfce4`,
you're golden.


