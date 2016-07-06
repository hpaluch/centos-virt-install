### CentOS guest automated install using virt-install

Here are sample scripts how to do fully automated installation
of CentOS guest in KVM using `virt-install`.

## Setup

The host OS (physical computer) is expected to be Ubuntu 16.04 LTS, 64-bit.

* Install KVM/virt-install packages in your Ubuntu host:
```bash
sudo apt-get install virt-manager qemu-kvm libvirt-bin \
                     ubuntu-vm-builder bridge-utils virt-viewer \
                     virt-install
``` 

> Please Logout/Login to ensure that you are member of new
> `libvirtd` group

* Install mtools (used for kickstart floppy creation):
```bash
sudo apt-get install mtools
```

* create directory for kickstart floppy:
```bash
sudo mkdir /var/local/floppies
sudo chgrp libvirtd /var/local/floppies
sudo chmod g+w  /var/local/floppies
```

* Add to your `/etc/mtools.conf` new line:
```
drive k: file="/var/local/floppies/kickstart.img"
```

* Run script for kicstart floppy creation:
```bash
./10_prepare_ks_floppy.sh
```

* there should be output like:
```
 Volume in drive K is KICKSTART  
 Volume Serial Number is 75A0-5761
Directory for K:/

ks       cfg      1304 2016-07-06  11:52 
        1 file                1 304 bytes
                          1 456 128 bytes free

```

* Get CentOS 6.6 ISO image (DVD) and save it into proper location.
  These scripts expect:
```
/opt/install/OS/CentOS6.6/CentOS-6.6-x86_64-bin-DVD1.iso
```
* Mount this ISO image under `/isos/centos6_dvd1` using
  instructions on <https://github.com/hpaluch/hpaluch.github.io/wiki/Using-autofs-to-mount-ISO-images>  
* Verify that the expaned tree really works:
```
 ls -l /isos/centos6_dvd1/
total 712
-r--r--r-- 2 root root     14 Oct 24  2014 CentOS_BuildTag
dr-xr-xr-x 3 root root   2048 Oct 24  2014 EFI
-r--r--r-- 2 root root    212 Nov 27  2013 EULA
-r--r--r-- 2 root root  18009 Nov 27  2013 GPL
dr-xr-xr-x 2 root root 686080 Oct 24  2014 Packages
...
```

* Create directory for VM disks:
```bash
sudo mkdir -p /opt/virtual-images/KVM
sudo chgrp libvirtd /opt/virtual-images/KVM
sudo chmod g+rwxs /opt/virtual-images/KVM
```

* Verify settings in `99_create_vm.sh` especially pathnames:
```
...
distiso=/opt/install/OS/CentOS6.6/CentOS-6.6-x86_64-bin-DVD1.iso
distdir=/isos/centos6_dvd1
fd=/var/local/floppies/kickstart.img
...
disk="/opt/virtual-images/KVM/${vm}.raw"
...
```

* Finally you can create vm using command like:
```bash
./99_create_vm.sh mycentos1
```

> To find guest root password use this command:
```bash
grep rootpw centos6-wipe-disk-ks.cfg
```

> NOTE: after every change of `centos6-wipe-disk-ks.cfg` you need to
> recreate kickstart floppy image using script:

```bash
./10_prepare_ks_floppy.sh
```


## FAQ

# Why don't use `--location ISO` to avoid need for expanded ISO tree?

There are two problems this approach:

* `virt-install` would need root privileges in such case (because it uses `mount` command)
* running `virt-install` messes up disk drive permissions (CentOS guest would be unable to find
  vda disk device)



