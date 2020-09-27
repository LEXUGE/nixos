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
	if [ "$1" = "-n" ]; then
		ROOT_PARTITION="${device}p2"
		ESP_PARTITION="${device}p1"
	else
		ROOT_PARTITION="${device}2"
		ESP_PARTITION="${device}1"
	fi
	echo "Root partition: ${ROOT_PARTITION}"
	echo "ESP partition: ${ESP_PARTITION}"
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
	dd bs=512 count=4 if=/dev/random of=${MOUNTPOINT}/etc/nixos/secrets/keyfile.bin iflag=fullblock
	echo "Add key to root partition"
	cryptsetup luksAddKey "${ROOT_PARTITION}" ${MOUNTPOINT}/etc/nixos/secrets/keyfile.bin
	chmod 600 ${MOUNTPOINT}/etc/nixos/secrets/keyfile.bin
}

# NIXOS_INSTALL
nixos_install() {
	git clone https://github.com/LEXUGE/nixos ${MOUNTPOINT}/etc/nixos/

	rm ${MOUNTPOINT}/etc/nixos/secrets/keyfile.bin
	rm ${MOUNTPOINT}/etc/nixos/hardware-configuration.nix

	create_keyfile
	reset

	# Create new options.nix and open it to let user customize.
	echo "Generate and open build options for configuration..."
	read -n 1 -s -r -p "[CONFIG] Adapt whatever on your needs. Press any key to continue"
	nano ${MOUNTPOINT}/etc/nixos/configuration.nix
	reset
	read -n 1 -s -r -p "[USERS] In the next step, you MUST change the user passwords, else you are gonna to be locked out. Press any key to continue"
	nano ${MOUNTPOINT}/etc/nixos/src/users.nix
	reset
	read -n 1 -s -r -p "[CLASH] In the next step, you'd better set up the appropriate proxy if you are not in a free Internet. Press any key to continue"
	nano ${MOUNTPOINT}/etc/nixos/secrets/clash.yaml
	reset
	nixos-generate-config --root ${MOUNTPOINT}

	# FIXME: Don't know why we need no-check-sigs
	nix copy --to ${MOUNTPOINT} "nixpkgs#nixFlakes" --no-check-sigs

	# Impure flag is needed because nix thinks `/mnt/nix/store` as a non-store path
	nix build "${MOUNTPOINT}/etc/nixos#x1c7-toplevel" --option store ${MOUNTPOINT} --impure

	# Install NixOS. We don't need root password
	nixos-install --system "$(readlink ./result)" --no-root-passwd

	reboot
}

# INSTALLATION
select_device "$@"
create_partition
format_partition
mount_partition
nixos_install
