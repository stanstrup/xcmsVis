#!/bin/bash

# Install system dependencies needed for R packages

echo "Installing system dependencies for R packages..."

sudo apt update

sudo apt install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  pandoc

echo "System dependencies installed!"
echo "Now you can install R packages."
