#!/usr/bin/env bash

set -e

rm -rf ./modules/ \
	./src/ \
	rm -f ./*.nix
rm -f ./*.lock

echo -n "Copying..."
rsync -avP \
	--exclude "secrets/" \
	--include "*/" \
	--include "*.nix" \
	--include "*.patch" \
	--include "*.json" \
	--include "*.lock" \
	--exclude "*" \
	/etc/nixos/ .

find . -type f -name '*.nix' -exec nixfmt {} +
shellcheck ./*.sh || true
shfmt -w ./*.sh
nix flake update --recreate-lock-file
nix flake check
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
