#!/usr/bin/env bash

rm -rf ./system/ \
	./dotfiles/ \
	./packages/ \
	./modules/ \
	./overlays/ \
	./users/ \
	./devices/ \
	./secrets/

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
