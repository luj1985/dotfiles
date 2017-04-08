# Erase disk
```{bash id:"j19gw836"}
# securely delete individual files or full devices
# https://www.gnu.org/software/coreutils/manual/html_node/shred-invocation.html
shred --verbose --random-source=/dev/urandom -n1 /dev/nvme0n1
```

# Partition
```{bash id:"j19gwcal"}
gdisk /dev/nvme0n1
# EFI boot partition
n 1 <ENTER> +100M EF00
# root partition
n 2 <ENTER> <ENTER> <ENTER>
w
```

# Encryption
```{bash id:"j19gwhhp"}
# dm-crypt
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 1000 --use-random --verify-passphrase luksFormat /dev/nvme0n1p2

# dm key files
dd if=/dev/random of=/tmp/luks-key bs=512 count=4
cryptsetup luksAddKey /dev/nvme0n1p2 /tmp/luks-key
cryptsetup luksOpen /dev/nvme0n1p2 crypt -d /tmp/luks-key
```

# File system
```{bash id:"j19gwmd6"}
mkfs.vfat -F32 -n "EFI" /dev/nvme0n1p1
mkfs.btrfs -KL "System" /dev/mapper/crypt

# Mount and the BTRFS volume && Create subvolumes
mkdir -p /mnt/arch
mount -o ssd,discard,noatime,compress=lzo /dev/mapper/crypt /mnt/arch
cd /mnt/arch
btrfs subvolume create __active

cd __active
btrfs subvolume create ROOT
btrfs subvolume create home
btrfs subvolume create var

mkdir -p /mnt/arch-active && cd /mnt/arch-active
mount -o ssd,discard,noatime,compress=lzo,nodev,subvol=__active/ROOT /dev/mapper/crypt /mnt/arch-active
mkdir -p /mnt/arch-active/{home,var,boot}

mount /dev/nvme0n1p1 /mnt/arch-active/boot
mount -o ssd,discard,noatime,compress=lzo,nosuid,nodev,subvol=__active/home /dev/mapper/crypt /mnt/arch-active/home
mount -o ssd,discard,noatime,compress=lzo,nosuid,nodev,subvol=__active/var /dev/mapper/crypt /mnt/arch-active/var
df -hT
```

# Install Arch base system
```{bash id:"j19gwt67"}
vim /etc/pacman.d/mirrorlist # choose fastest mirrors
pacstrap /mnt/arch-active base base-devel cryptsetup btrfs-progs vim

mv /tmp/luks-key /mnt/arch-active/root/
chmod 000 /mnt/arch-active/root/luks-key

# fstab
genfstab -pU /mnt/arch-active >> /mnt/arch-active/etc/fstab

# chroot
arch-chroot /mnt/arch-active /bin/bash

# time
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo vulture >> /etc/hostname
locale-gen

# kernel
# add "encrypt" into HOOS
vi /etc/mkinitcpio.conf

mkinitcpio -p linux
bootctl --path=/boot install

cat << EOF > /boot/loader/loader.conf
default arch
timeout 1
editor  0
EOF

blkid

cat << EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options cryptdevice=UUID=b5178df0-a889-4618-bfd4-a55d3c8793d3:crypt root=/dev/mapper/crypt rootflags=subvol=__active/ROOT rw
EOF

passwd

umount -R /mnt/arch-active
umount -R /mnt/arch
reboot
```

# systemd
```{bash id:"j19gwyti"}
# setup network
cat << EOF > /etc/systemd/network/50-wired.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

systemctl enable systemd-networkd
systemctl start systemd-networkd

systemctl enable systemd-resolved
systemctl start systemd-resolved

rm /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# ntp
timedatectl set-ntp true

# edit /etc/systemd/journald.conf
# otherwise /var cannot be umounted correctly
Storage=volatile
```

# configure system
```{bash id:"j19gx3yh"}
useradd -m -d /home/lujun -s /bin/bash lujun
gpasswd -a lujun wheel

pacman -S openssh
systemctl enable sshd
systemctl start sshd

cat << EOF >> /etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustAll
Server = http://mirrors.163.com/archlinux-cn/$arch
EOF

pacman -S archlinuxcn-keyring
pacman -S yaourt
```

# Backup
```{bash id:"j19gx9r8"}
pacman -S snapper
snapper -c config create-config /

systemctl enable snapper-timeline.timer
systemctl start snapper-timeline.timer
```

# Xorg
```{bash id:"j19gxctp"}
yaourt -S xorg-server xorg-xinit nvidia i3-wm i3statu google-chrome xterm rofi
yaourt -S font-bitstream-speedo ttf-bitstream-vera ttf-dejavu ttf-hack
yaourt -S alsa-utils

yaourt -S wqy-microhei wqy-zenhei adobe-source-han-sans-cn-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji
yaourt -S fcitx fcitx-im fcitx-sogoupinyin

sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/

yaourt -S htop lsof strace
```
