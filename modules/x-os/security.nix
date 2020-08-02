{ config, lib, ... }: {
  # We don't want fingerprint auth on login (It is awkward to have multiple failed attempts on unlocking, and someone may inflict me to press and unlock.
  # Even if fprintd is not enabled, following rules make sense as well.
  security.pam.services = builtins.listToAttrs
    (map (n: lib.attrsets.nameValuePair (n) ({ fprintAuth = false; })) [
      "login" # GDM's gdm-password pam config includes login file, so it works for both.
      "i3lock"
      "i3lock-color"
      "xlock"
      "vlock"
    ]);
}
