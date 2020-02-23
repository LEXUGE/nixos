# nixos
A fully automated replicable nixos configuration set. Tested on Virtualbox and ThinkPad X1 Carbon 7th Gen. It should be working on any x86 machine.

# What does it do?
It features:
- GNOME 3 with builtin dark variant.
- Full-disk encryption including `/boot`.
- Switchable transparent proxy backended by `shadowsocks-libev + simple-obfs` (I
  packaged simple-obfs myself). This feature is **extremely** useful if you are
  in Mainland China because it helps you get over the firewall without pain.
- <kbd>CapsLock</kbd> as <kbd>Ctrl</kbd>! No emacs pinky anymore! (Surely I am
  an emacs user).
- zsh with oh-my-zsh builtin, in addition to a git plugin which makes your life
  easier.
- An almost automated onliner installation script.

# How do I install it?
**NOTE:** If you are not on a NVMe SSD, please edit the script to fit
    `"${device}p2"` into `"${device}2"` (so does `"${device}p1"`).

Boot in NixOS LiveCD, and then:

``
curl -Ls https://github.com/LEXUGE/nixos/raw/master/install.sh | bash
``

Follow the instructions and there you go.

If you want to use `shadowsocks`, please create `secrets/shadowsocks.json`.

# How do I steal it?
It's actually not well-structured for stealing. But here are some
instructions:
- If you want to use my packaged
  [simple-obfs](https://github.com/shadowsocks/simple-obfs), just grab
  `packages/simple-obfs.nix`.
- See `nesting.nix` if you want to use switchable transparent proxy.

# See also
[config](https://github.com/LEXUGE/config) for my emacs and other configs (may
integrate into this repository later).

# Acknowledgments
Thanks to following repositories:
- [Jollheef - localhost](https://github.com/jollheef/localhost). It inspired me
the general structure of the config and how to use home-manager.
- [Ninlives - nixos-config](https://github.com/Ninlives/nixos-config). It
  inspired me to implement the switchable transparent proxy function based on `nesting`.
