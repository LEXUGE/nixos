#!/usr/bin/env bash

rm -rf ./dotfiles/ \
	./plugins/ \
	./secrets/
rm ./*.nix
rm ./*.nix.example

echo -n "Copying..."
rsync -avP \
	--include "*/" \
	--include "*.*.example" \
	--include "*.nix" \
	--include "*.el" \
	--include "*.ini" \
	--include "*.patch" \
	--include "*.json" \
	--exclude "*" \
	/etc/nixos/ .

cp configuration.nix configuration.nix.example
find . -type f -name '*.nix' -exec nixfmt {} +
find . -type f -name '*.nix.example' -exec nixfmt {} +
shellcheck ./*.sh
shfmt -w ./*.sh
echo "Done."

echo -n "Adding to git..."
git add --all
echo "Done."

git status
read -n 1 -s -r -p "Press any key to continue"

echo "Commiting..."
echo "Enter commit message: "
read -r commitMessage
git commit -m "$commitMessage"
echo "Done."

echo -n "Pushing..."
git push
echo "Done."
