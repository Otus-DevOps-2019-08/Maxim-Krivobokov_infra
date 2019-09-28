#!/bin/bash
set -e
#installing ruby and build
apt-get update
apt-get install -y ruby-full ruby-bundler
apt-get install -y build-essential

#echo "All components are installed successfully (if you don't see error messages)"
