

distiso=/opt/install/OS/CentOS6.6/CentOS-6.6-x86_64-bin-DVD1.iso
distdir=/isos/centos6_dvd1
fd=/var/local/floppies/kickstart.img

[ $# -eq 1 ] || {

	echo "Usage: $0 vm_name"
	exit 1
}
vm="$1"
invalid_chars=`echo "$vm" | tr -d 'a-z' | tr -d 'A-Z' | tr -d '0-9' | tr -d  '-'`
[ -n "$invalid_chars" ] && {
	echo "VM name contains forbidden characters: $invalid_chars"
	echo "Use only: a-z A-Z 0-9 - (must be valid hostname)"
	exit 2
}

disk="/opt/virtual-images/KVM/${vm}.raw"

set -xe
cd `dirname $0`
# sudo required for --location ISO (it uses mount command)
# otherwise we would need also expanded ISO tree (for example using autofs)
virt-install \
              --virt-type kvm \
              --name "$vm" \
              --ram 768 \
              --disk "$disk,size=8,sparse=true" \
	      --disk "$fd,device=floppy" \
              --disk "$distiso,device=cdrom" \
              --vnc \
              --location $distdir \
              -x "text ks=floppy FQDN=$vm.kvm.dom"

cat <<EOF
Use these commands to completely destroy this VM:

virsh destroy $vm
virsh undefine $vm
rm $disk
EOF

