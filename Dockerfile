FROM ubuntu:focal

RUN apt-get -y update

# Install sudo command...
RUN apt-get -y install sudo

ENV DOCKER_USER raldo

# To avoid interactive dialogue
ARG DEBIAN_FRONTEND=noninteractive

# Start by creating our passwordless user.
RUN adduser --disabled-password --gecos '' "$DOCKER_USER"

# Give root priviledges
RUN adduser "$DOCKER_USER" sudo

# Give passwordless sudo. This is only acceptable as it is a private
# development environment not exposed to the outside world. Do NOT do this on
# your host machine or otherwise.
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Need to be root in order to set timezone
USER root

# Timezone
ENV TZ="Europe/Stockholm"
RUN sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && sudo echo $TZ > /etc/timezone

USER "$DOCKER_USER"

# install wget and stow
RUN sudo apt-get install -y wget stow

# install oh-my-zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t arrow \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# This will determine where we will start when we enter the container.
WORKDIR "/home/$DOCKER_USER"

# The sudo message is annoying, so skip it
RUN touch ~/.sudo_as_admin_successful

RUN sudo apt-get install -y tzdata

# Commons
RUN sudo apt-get install -y build-essential curl git openssh-client man-db software-properties-common bash-completion

# Now add the repository for neovim
RUN sudo add-apt-repository ppa:neovim-ppa/unstable

# Update registry
RUN sudo apt-get update

# Install the real deal
RUN sudo apt-get install neovim -y

# Install packer.nvim, a neovim package manager
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# cmake
RUN sudo apt-get install -y cmake

# we also need python neovim, so we need to get and update pip3
RUN sudo apt-get install -y python3-pip && \
	sudo pip3 install --upgrade pip && \
	sudo pip3 install neovim

# Install tmux
RUN sudo apt-get install -y tmux

## Tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

## Tmux requires the TERM environment variable to be set to this specific value
## to run as one would expect.
ENV TERM=screen-256color

# cht.sh
RUN curl https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh

# fasd repo cause its FASD
RUN sudo add-apt-repository ppa:aacebedo/fasd

# Get up to speed
RUN sudo apt-get update

## ranger, fasd, ripgrep...
RUN sudo apt-get install -y ranger screen fasd tldr fzf x11-xserver-utils virtualenv ripgrep xclip net-tools fping dnsutils nmap direnv fd-find

## Ruby
RUN sudo apt-get install -y ruby-dev

## Switch back to our normal directory
WORKDIR /home/$DOCKER_USER

## Get docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Make docker runnable without sudo
RUN sudo usermod -aG docker $DOCKER_USER

# Get docker-compose
RUN sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
RUN sudo chmod +x /usr/local/bin/docker-compose

# Azure, perhaps I should branch of?
RUN sudo apt-get install -y azure-cli

# Add gpg key and repository for hashicorp
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
RUN sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install terraform and packer
RUN sudo apt-get update -y && sudo apt-get install terraform packer

# Install jq for json parsing
RUN sudo apt-get install -y jq

# get the nvm install script and run it
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash

# set the environment variable
ENV NVM_DIR /home/$DOCKER_USER/.nvm

# source nvm, install the version we want, alias that version so it always loads
RUN . "$NVM_DIR/nvm.sh" && \
	nvm install --lts && \
	nvm alias default stable

# add dotfiles repo here to detect changes to head, I do this to prevent using
# cached layers when there is a change to the repo.
ADD https://api.github.com/repos/anguse/dotfiles/git/refs/heads/nvim-lsp version.json

# clone and change to use ssh url to be able to push changes from within
# the container.
RUN git clone https://github.com/anguse/dotfiles --branch nvim-lsp /home/$DOCKER_USER/.dotfiles && \
    cd /home/$DOCKER_USER/.dotfiles && \
    git remote rm origin && \
    git remote add origin git@github.com:Anguse/dotfiles.git

# Stow is used to create symlinks to the different config files
ENV STOW_FOLDERS = "ranger, zsh, nvim, tmux, bin, git"

# Remove default .zshrc
RUN rm /home/$DOCKER_USER/.zshrc

# Setup with stow
RUN cd /home/$DOCKER_USER/.dotfiles && zsh install

# Install all plugins
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c "lua require('packer').sync()"

# Install tmux plugins
RUN /home/$DOCKER_USER/.tmux/plugins/tpm/scripts/install_plugins.sh

# THINGS TO ADD:
# * git config

CMD [ "zsh" ]
