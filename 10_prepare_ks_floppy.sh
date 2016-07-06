#!/bin/bash


drive=k:

set -ex
cd `dirname $0`
#dd if=/dev/zero of=$image bs=512 count=2880
mformat -C -v KICKSTART -f 1440 $drive
mcopy centos6-wipe-disk-ks.cfg ${drive}ks.cfg
mdir $drive

