#!/usr/bin/env bash

rm -rf ./*.nix ./dotfiles/ ./packages/ ./modules/

cp -a /etc/nixos/secrets/*.example ./secrets/.
cp -a /etc/nixos/*.nix ./
cp -a /etc/nixos/dotfiles ./
cp -a /etc/nixos/packages ./
cp -a /etc/nixos/modules ./
find . -type f -name '*.nix' -exec nixfmt {} +

git add --all
echo "Enter commit message: "
read commitMessage
git commit -m "$commitMessage"
git push
