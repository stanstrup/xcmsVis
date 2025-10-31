#!/bin/bash

# Script to install the latest R version in WSL Ubuntu

echo "Installing latest R version in WSL..."

# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y --no-install-recommends software-properties-common dirmngr wget

# Add CRAN GPG key
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -cs)
echo "Detected Ubuntu version: $UBUNTU_VERSION"

# Add R repository
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $UBUNTU_VERSION-cran40/"

# Update package list again
sudo apt update

# Install R
sudo apt install -y r-base r-base-dev

# Verify installation
R --version

echo ""
echo "R installation complete!"
echo "Now installing required R packages..."

# Install R packages
sudo Rscript -e "install.packages(c('pkgdown', 'devtools', 'roxygen2', 'remotes', 'BiocManager'), repos='https://cloud.r-project.org', Ncpus=4)"

# Install Bioconductor packages
sudo Rscript -e "BiocManager::install(c('xcms', 'MsExperiment', 'MSnbase', 'BiocStyle'), update=FALSE, ask=FALSE)"

echo ""
echo "All R packages installed!"
echo "You can now build the pkgdown site with:"
echo "  cd /mnt/c/Users/tmh331/Desktop/gits/xcmsVis"
echo "  Rscript -e \"pkgdown::build_site()\""
