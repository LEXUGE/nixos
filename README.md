# NixOS
![Screenshot](Screenshot.png)
A fully automated replicable nixos configuration set. Tested on Virtualbox and ThinkPad X1 Carbon 7th Gen. It should be working on any x86 machine.

# What does it do?
** FOLLOWING MAY BE OUTDATED, I WOULD UPDATE IT SOON**
It features:
- GTK with builtin dark variant.
- Full-disk encryption including `/boot`.
- Working Howdy (Windows Hello like login service) on X1 Carbon 7th Gen
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

If you want to use `shadowsocks`, please create `secrets/shadowsocks.json`.

## Note
If you are not on a NVMe SSD, please edit the script to fit `"${device}p2"` into `"${device}2"` (so does `"${device}p1"`).

If you are outside of Mainland China, please edit the script to use official binary cache only instead of TUNA's. You may also need to adapt the `binaryCaches` setting in `system/options.nix` to your own network.

# Structure of the configuration
The system configuration could be split up into three pieces, system-wide, user-land, and device-specifications.
- User-land `users/`: I would do some personal configuration here, this would include which shell to use for specific user, what packages to install, etc.
- Device-specifications `devices/`: This would include some non-universal device specific configurations like `TLP` power management and `fprintd` fingerprint auth.
- System: Rest of them are a re-usable system with my personal flavor added (e.g. `smartdns` and transparent proxy for better networking experience).

# Security details
As for me, I am on my best to ensure that the system is convenient to use and secure. But here are some concerns:
- `services.fstrim.enable` is set to `true` which means that attacker may be able to perceive the data usage of the fully encrypted disk.
- `howdy` is not suggested to use if you need to ensure high level security due to the potentiality of spoofing.
- There is keyfile added to `/` partition encryption in order to eliminate the twice keying in of the LUKS passphrase. This may imply security concerns.

# How do I steal it?
It's actually not well-structured for stealing. But here are some
instructions:
- If you want to use my packaged
  [simple-obfs](https://github.com/shadowsocks/simple-obfs), just grab
  `packages/simple-obfs.nix`.
- See `proxy.nix` if you want to use transparent proxy.
- If you want to use my [smartdns](https://github.com/pymumu/smartdns), take a look into `packages/smartdns.nix` and `modules/smartdns.nix`.
- See `packages/ir_toggle.nix`, `packages/howdy.nix`, `modules/ir_toggle.nix`, `modules/howdy.nix` if you want to use Howdy on X1 Carbon 7th Gen (20R1). (**Tip:** if you are not on X1 Carbon 7th Gen, you would probably not need `ir_toggle` in order to get it work.)

# See also
[config](https://github.com/LEXUGE/config) for my emacs and other configs (may
integrate into this repository later).

# Acknowledgments
Thanks to following repositories:
- [Jollheef - localhost](https://github.com/jollheef/localhost). It inspired me
the general structure of the config and how to use home-manager.
- [Ninlives - nixos-config](https://github.com/Ninlives/nixos-config). It
  inspired me to implement the transparent proxy functionality.
