#!/usr/bin/env bash

rm -rf ./*.nix ./dotfiles/ ./packages/ ./modules/ ./overlays/

echo -n "Copying..."
cp -a /etc/nixos/secrets/*.example ./secrets/.
cp -a /etc/nixos/*.nix ./
cp -a /etc/nixos/dotfiles ./
cp -a /etc/nixos/packages ./
cp -a /etc/nixos/modules ./
cp -a /etc/nixos/overlays ./
find . -type f -name '*.nix' -exec nixfmt {} +
echo "Done."

echo -n "Adding to git..."
git add --all
echo "Done."

echo "Commiting..."
echo "Enter commit message: "
read -r commitMessage
git commit -m "$commitMessage"
echo "Done."

echo -n "Pushing..."
git push
echo "Done."
