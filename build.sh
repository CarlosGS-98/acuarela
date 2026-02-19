#!/usr/bin/env bash

# [AUTHOR]: Carlos González Sanz

# This is (for the most part) a temporary build script
# that should probably be replaced with a proper
# root Makefile inside this repo.
cd Acuarela/
perl -I lib/Acuarela.pm Makefile.PL
make
make test
make install
cd -
