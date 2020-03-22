#!/usr/bin/env bash

rm -rf ./src \
	./dotfiles/ \
	./packages/ \
	./modules/ \
	./overlays/ \
	./secrets/
rm ./*."{nix, nix.example}"

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
find . -type f -name '*.nix' -exec nixfmt {} +
find . -type f -name '*.nix.example' -exec nixfmt {} +
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
