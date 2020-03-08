# NixOS
A fully automated replicable nixos configuration set. Tested on Virtualbox and ThinkPad X1 Carbon 7th Gen. It should be working on any x86 machine.

# What does it do?
It features:
- GNOME 3 with builtin dark variant.
- Full-disk encryption including `/boot`.
- Transparent proxy backended by `shadowsocks-libev + simple-obfs` (I
  packaged simple-obfs myself). This feature is **extremely** useful if you are
  in Mainland China because it helps you get over the firewall without pain.
- A built-in smartdns server (custom packaged)
- <kbd>CapsLock</kbd> as <kbd>Ctrl</kbd>! No emacs pinky anymore! (Surely I am
  an emacs user).
- zsh with oh-my-zsh builtin, in addition to a git plugin which makes your life
  easier.
- An almost automated one-liner installation script.

# How do I install it?
Boot in NixOS LiveCD, and then:

``
curl -Ls https://github.com/LEXUGE/nixos/raw/master/install.sh | bash
``

Follow the instructions and there you go.

After installastion, `sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable unstable` (If you are outside Mainland China, use `sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable`).

If you want to use `shadowsocks`, please create `secrets/shadowsocks.json`.

## Note
If you are not on a NVMe SSD, please edit the script to fit `"${device}p2"` into `"${device}2"` (so does `"${device}p1"`).

If you are outside of Mainland China, please edit the script to use official channel instead of TUNA channel mirror. You may also need to delete the `binaryCaches` setting in `configuration.nix`.

After installation, in regular uses, do remeber to run `sudo nix-channel --update` regularly in order to upgrade `unstable` channel which would not be upgraded automatically.

# Structure of the configuration
The system configuration could be split up into three pieces, system-wide, user-land, and device-specifications.
- User-land `users/`: I would do some personal configuration here, this would include which shell to use for specific user, what packages to install, etc.
- Device-specifications `devices/`: This would include some non-universal device specific configurations like `TLP` power management and `fprintd` fingerprint auth.
- System: Rest of them are a re-usable system with my personal flavor added (e.g. `smartdns` and transparent proxy for better networking experience).

# How do I steal it?
It's actually not well-structured for stealing. But here are some
instructions:
- If you want to use my packaged
  [simple-obfs](https://github.com/shadowsocks/simple-obfs), just grab
  `packages/simple-obfs.nix`.
- See `proxy.nix` if you want to use transparent proxy.
- If you want to use my [smartdns](https://github.com/pymumu/smartdns), take a look into `packages/smartdns.nix` and `modules/smartdns.nix`.

# See also
[config](https://github.com/LEXUGE/config) for my emacs and other configs (may
integrate into this repository later).

# Acknowledgments
Thanks to following repositories:
- [Jollheef - localhost](https://github.com/jollheef/localhost). It inspired me
the general structure of the config and how to use home-manager.
- [Ninlives - nixos-config](https://github.com/Ninlives/nixos-config). It
  inspired me to implement the transparent proxy functionality.
