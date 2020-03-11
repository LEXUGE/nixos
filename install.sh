#!/usr/bin/env bash

set -e

prompt1="Enter your option: "
ESP="/boot/efi"
MOUNTPOINT="/mnt"

contains_element() {
	#check if an element exist in a string
	for e in "${@:2}"; do [[ $e == "$1" ]] && break; done
}

#SELECT DEVICE
select_device() {
	devices_list=($(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'))
	PS3="$prompt1"
	echo -e "Attached Devices:\n"
	lsblk -lnp -I 2,3,8,9,22,34,56,57,58,65,66,67,68,69,70,71,72,91,128,129,130,131,132,133,134,135,259 | awk '{print $1,$4,$6,$7}' | column -t
	echo -e "\n"
	echo -e "Select device to partition:\n"
	select device in "${devices_list[@]}"; do
		if contains_element "${device}" "${devices_list[@]}"; then
			break
		else
			exit 1
		fi
	done
	ROOT_PARTITION="${device}p2"
	ESP_PARTITION="${device}p1"
}

#CREATE_PARTITION
create_partition() {
	wipefs -a "${device}"
	# Set GPT scheme
	parted "${device}" mklabel gpt &>/dev/null
	# Create ESP for /efi
	parted "${device}" mkpart primary fat32 1MiB 512MiB &>/dev/null
	parted "${device}" set 1 esp on &>/dev/null
	# Create /
	parted "${device}" mkpart primary 512MiB 100% &>/dev/null
}

#FORMAT_PARTITION
format_partition() {
	mkfs.fat -F32 "${ESP_PARTITION}" >/dev/null
	echo "LUKS Setup for '/' partition"
	cryptsetup luksFormat --type luks1 -s 512 -h sha512 -i 3000 "${ROOT_PARTITION}"
	echo "Open '/' partition"
	cryptsetup open "${ROOT_PARTITION}" cryptroot
	mkfs.ext4 /dev/mapper/cryptroot >/dev/null
}

#MOUNT_PARTITION
mount_partition() {
	mount /dev/mapper/cryptroot "${MOUNTPOINT}"
	mkdir -p "${MOUNTPOINT}"${ESP}
	mount "${ESP_PARTITION}" "${MOUNTPOINT}"${ESP}
}

#CREATE_KEYFILE
create_keyfile() {
	dd bs=512 count=4 if=/dev/random of=${MOUNTPOINT}/keyfile.bin iflag=fullblock
	echo ${MOUNTPOINT}/keyfile.bin | cpio -o -H newc -R +0:+0 --reproducible | gzip -9 >${MOUNTPOINT}/boot/initrd.keys.gz
	echo "Add key to root partition"
	cryptsetup luksAddKey "${ROOT_PARTITION}" ${MOUNTPOINT}/keyfile.bin
	chmod 600 ${MOUNTPOINT}/keyfile.bin
	chmod 600 ${MOUNTPOINT}/boot/initrd.keys.gz
}

# NIXOS_INSTALL
nixos_install() {
	nix-channel --add https://nixos.org/channels/nixos-unstable nixos
	nix-channel --update

	# Install git by using TUNA binary cache with fallback
	nix-env -iA nixos.gitMinimal --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/"
	git clone https://github.com/LEXUGE/nixos /mnt/etc/nixos/
	rm -rf /mnt/etc/nixos/.git/

	# Create new options.nix and open it to let user customize.
	echo "Generate and open build options for configuration..."
	read -n 1 -s -r -p "Press any key to continue"
	cp /mnt/etc/nixos/system/options.nix.example /mnt/etc/nixos/system/options.nix
	nano /mnt/etc/nixos/system/options.nix

	# Install NixOS using TUNA binary cache with fallback
	nixos-generate-config --root /mnt
	nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/"

	reboot
}

# INSTALLATION
select_device
create_partition
format_partition
mount_partition
create_keyfile
nixos_install
