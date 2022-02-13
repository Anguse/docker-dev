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
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)"

# This will determine where we will start when we enter the container.
WORKDIR "/home/$DOCKER_USER"

# The sudo message is annoying, so skip it
RUN touch ~/.sudo_as_admin_successful

RUN sudo apt-get install -y tzdata

# We will need this to build c/c++ dependencies. This is common enough
# in all my various projects that I include it in my base image; there are
# often transitive dependencies in Python/NodeJs/Rust projects which require
# c/c++ compilation.
RUN sudo apt-get install -y build-essential curl git openssh-client man-db bash-completion software-properties-common

# Now add the repository for neovim
RUN sudo add-apt-repository ppa:neovim-ppa/unstable

# Update registry
RUN sudo apt-get update

# Install the real deal
RUN sudo apt-get install neovim -y

# Install vim-plug, our plugin manager
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Stow is used to create symlinks to the different config files
ENV STOW_FOLDERS = "ranger, zsh, nvim, tmux, bin, git"

# Remove default .zshrc
RUN rm /home/$DOCKER_USER/.zshrc

# dotfiles
RUN git clone https://github.com/anguse/dotfiles /home/$DOCKER_USER/.dotfiles

# Setup with stow
RUN cd /home/$DOCKER_USER/.dotfiles && zsh install

# Install all of our plugins
RUN nvim +PlugInstall +qall

# get the nvm install script and run it
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# set the environment variable
ENV NVM_DIR /home/$DOCKER_USER/.nvm

# source nvm, install the version we want, alias that version so it always loads
RUN . "$NVM_DIR/nvm.sh" && \
	nvm install --lts && \
	nvm alias default stable

# cmake needed for YMC
RUN sudo apt-get install -y cmake

# we also need python neovim, so we need to get and update pip3
RUN sudo apt-get install -y python3-pip && \
	sudo pip3 install --upgrade pip && \
	sudo pip3 install neovim

# source nvm and run the python youcompleteme installer with JS
RUN . "$NVM_DIR/nvm.sh" && \
   python3 "$HOME/.config/nvim/plugged/YouCompleteMe/install.py" --js-completer

# Install tmux
RUN sudo apt-get install -y tmux

## Tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install tmux plugins
RUN /home/$DOCKER_USER/.tmux/plugins/tpm/scripts/install_plugins.sh

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
RUN sudo apt-get install -y ranger screen fasd tldr fzf x11-xserver-utils virtualenv ripgrep xclip net-tools

## Switch back to our normal directory
WORKDIR /home/$DOCKER_USER

## Get docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Make docker runnable without sudo
RUN sudo usermod -aG docker $DOCKER_USER

## git config
## setup ycm for different languages?
## python, virtualenv?
## ripgrep
## fdfind

CMD [ "zsh" ]
