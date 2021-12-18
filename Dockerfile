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

USER "$DOCKER_USER"
#
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
RUN sudo add-apt-repository ppa:neovim-ppa/stable

# Update the package listing
RUN sudo apt-get update

# Install the real deal
RUN sudo apt-get install neovim -y

# Create configuration directory for neovim
RUN mkdir -p "$HOME/.config/nvim"

# Copy our configuration
COPY ./init.vim /tmp/init.vim
RUN cat /tmp/init.vim > ~/.config/nvim/init.vim && \
	sudo rm /tmp/init.vim

# Install vim-plug, our plugin manager
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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
    python3 "$HOME/.config/nvim/plugged/YouCompleteMe/install.py" \
    --js-completer

RUN sudo apt-get install -y wget

# install oh-my-zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)"

ENV TMUX_VERSION 2.7

ENV TMUX_TAR "tmux-$TMUX_VERSION.tar.gz"

# Download the tmux archive
RUN curl -L -o "/tmp/tmux-$TMUX_VERSION.tar.gz" \
		"https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/$TMUX_TAR"
#
# Change our working directory to the location where our archive is
WORKDIR /tmp

# Untar the tmux source code
RUN tar xzf "$TMUX_TAR" -C /tmp

# Switch to the directory containing the extracted source code.
WORKDIR "/tmp/tmux-$TMUX_VERSION"

# Since we're building source code, we will require certain libraries to
# compiler against (header files) as well as library files which will be
# linked to the tmux program at runtime.
RUN sudo apt-get install -y libevent-2.1-7 libevent-dev libncurses-dev

# Generate configuration files and make sure all dependencies are present
RUN ./configure

# Build the tmux binary
RUN make

# Install tmux globally
RUN sudo make install

# Tmux requires the TERM environment variable to be set to this specific value
# to run as one would expect.
ENV TERM=screen-256color

# Copy our basic tmux configuration
COPY ./.tmux.conf /tmp/.tmux.conf
RUN cat /tmp/.tmux.conf > ~/.tmux.conf && \
	sudo rm /tmp/.tmux.conf

# ranger, fasd
RUN sudo apt-get install -y ranger

# Switch back to our normal directory
WORKDIR /home/$DOCKER_USER

# install fasd
# zshrc
# vim, nvim, powerline, ycm for different languages?
# fasd
# tmux, tmux config, plugins, scripts
# git config
# powerline?
# setup ycm for different languages?
# python, virtualenv?
# tldr
# volumes

CMD [ "zsh" ]
