# NixOS
![Build customized NixOS LiveCD ISO](https://github.com/LEXUGE/nixos/workflows/Build%20customized%20NixOS%20LiveCD%20ISO/badge.svg) ![Nix Flake Check](https://github.com/LEXUGE/nixos/workflows/Nix%20Flake%20Check/badge.svg) ![Release status](https://img.shields.io/github/v/release/LEXUGE/nixos.svg)  
A fully automated replicable nixos configuration flake that provides re-usable modules, and pre-configured system configuration.

# Features
- A customized LiveCD ISO that you can try environment out and speed up your installation!
- Full-disk encryption including `/boot`. Support hibernate.
- An almost automated one-liner installation script.
- Transparent proxy and de-polluted DNS server using Clash and [netkit.nix flake](https://github.com/icebox-nix/netkit.nix) (support shadowsocks, Vmess, trojan). rules are written in order to maximize the performance.
- <kbd>CapsLock</kbd> as <kbd>Ctrl</kbd>! No emacs pinky anymore! (Surely I am
  an emacs user).
- zsh with oh-my-zsh builtin, in addition to a git plugin which makes your life
  easier.
- GTK with builtin dark variant.

# How do I install pre-configured?
[Download](https://github.com/LEXUGE/nixos/releases) and boot in *customized* LiveCD, and then:

``
curl -Ls https://github.com/LEXUGE/nixos/raw/master/install.sh | bash
``

Follow the instructions and there you go. Above installation script will automatically install ThinkPad X1 Carbon 7th Gen specified configuration, but it should be fine for modern laptops.

If you want hibernate to work, please follow the instructions under `share.swapResumeOffset` in `configuration.nix`.

## Note
If you are not on a NVMe SSD, please edit the script to fit `"${device}p2"` into `"${device}2"` (so does `"${device}p1"`).

If you are **outside** of Mainland China, please edit the `configuration.nix` to use official binary cache only instead of TUNA's. You may also need to adapt the `binaryCaches` setting in `system/options.nix` to your own network.

# Security details
As for me, I am on my best to ensure that the system is convenient to use and secure. But here are some concerns:
- `services.fstrim.enable` is set to `true` which means that attacker may be able to perceive the data usage of the fully encrypted disk.
- There is keyfile added to `/` partition encryption in order to eliminate the twice keying in of the LUKS passphrase.

# How do I steal it?
I have kept "stealing" in mind while I am writing the whole configuration. Use `nix flake show 'github:LEXUGE/nixos'` to see what are available. For example,
```
github:LEXUGE/nixos/dd59c772a9bd0503da3c775427bbfed64d6dfc61
│   ├───ash-profile: NixOS module
│   ├───hm-sanity: NixOS module
│   └───x-os: NixOS module
```
- `ash-profile` is my user space configuration (stuff like zsh, git, emacs config, etc).
- `hm-sanity` is a proper fix to first-time deployment issue in home-manager.
- `x-os` my universal core system config.

# CI
I use GitHub Actions here to build nightly LiveCD actions (with all flake inputs up-to-date). This means by using the latest ISO image, you are likely to copy a trunk of stuff directly from CD (which is good because you don't need to download them!). After every successful build, my telegram bot would post newly built release to a [telegram channel](https://t.me/harry_nixosci_channel).

# See also
- [netkit.nix flake](https://github.com/icebox-nix/netkit.nix): Verstile tools for advanced networking scenarios in NixOS, including Clash, wifi-to-wifi hotspot, on demand minecraft server, frpc modules.
- [std](https://github.com/icebox-nix/std): Standard library used by my flakes.

# Acknowledgments
Thanks to following repositories:
- [Jollheef - localhost](https://github.com/jollheef/localhost). It inspired me
the general structure of the config and how to use home-manager.
- [Ninlives - nixos-config](https://github.com/Ninlives/nixos-config). It
  inspired me to implement the transparent proxy functionality.
- [nrdxp - nixflk](https://github.com/nrdxp/nixflk/). It helps me to implement the customized ISO building.
- [abcdw - rde](https://github.com/abcdw/rde/). Installation techniques.
