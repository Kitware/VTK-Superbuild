#!/usr/bin/env bash

# Make sure we are inside the repository.
cd "${BASH_SOURCE%/*}/.."

Scripts/GitSetup/setup-user && echo &&
Scripts/GitSetup/setup-hooks && echo &&
Scripts/setup-git-aliases && echo &&
(Scripts/GitSetup/setup-upstream ||
 echo 'Failed to setup origin.  Run this again to retry.') && echo &&
(Scripts/GitSetup/setup-gitlab ||
 echo 'Failed to setup GitLab.  Run this again to retry.') && echo &&
Scripts/GitSetup/tips

echo "Initializing and updating git submodules..."
git submodule update --init --recursive

# Rebase master by default
git config rebase.stat true
git config branch.master.rebase true

# Disable Gerrit hook explicitly so the commit-msg hook will
# not complain even if some gerrit remotes are still configured.
git config hooks.GerritId false

# Record the version of this setup so Scripts/pre-commit can check it.
SetupForDevelopment_VERSION=2
git config hooks.SetupForDevelopment ${SetupForDevelopment_VERSION}

echo "Setup for development complete for VTK-Superbuild."
