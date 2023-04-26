#!/bin/bash

# Init option {{{
Color_off='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

# verison
VERSION='0.0.1'
# system
SYSTEM="$(uname -s)"
INFO=$(cat /etc/issue)

function welcome() {
	echo -e "\033[36m
██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗     ██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║
██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝    ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║
██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝     ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║
██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║         ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝
╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝          ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ 
			Version: ${VERSION} 	by: lemon - liyp
			System:  ${INFO%\\l}
\033[0m"
}

# Log helper
msg() {
	printf '%b\n' "$1" >&2
}

info() {
	msg "${Blue}[➭]${Color_off} ${1}${2}"
}

warn() {
	msg "${Red}[►]${Color_off} ${1}${2}"
}

error() {
	msg "${Red}[✘]${Color_off} ${1}${2}"
	exit 1
}

fail() {
	msg "${Red}[✘]${Color_off} ${1}${2}"
}

success() {
	msg "${Green}[✔]${Color_off} ${1}${2}"
}

# check and install
cmdCheck() {
	if ! hash $1 &>/dev/null; then
		error "Command [${1}] not found"
	fi
	info "Command [${1}] exist"
}

aptInstall() {
	info "Install ${1}"
	warn "Waiting"
	if sudo apt-get install -y $1 >/dev/null; then
		success "Install ${1} Success"
	else
		fail "Install ${1} Failed"
	fi
}

terminalEnv() {
	case ${1} in
	# Install and Configure zsh
	1)
		if ! hash zsh &>/dev/null; then
			aptInstall zsh
		fi
		cmdCheck zsh
		info "Install oh-my-zsh"
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		sudo chsh -s $(which zsh)
		cp config/.alias ~/.alias
		cp config/.zshrc ~/.zshrc
		source ~/.zshrc
		git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
		ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		;;
	# Install and Configure tmux
	2)
		info "Install tmux"
		if ! hash tmux &>/dev/null; then
			aptInstall tmux
		fi
		cmdCheck tmux
		cp config/tmux.conf ~/.tmux.conf
		;;
	esac
}

rosDevelopmentEnv() {
	case ${1} in
	# Install ROS
	1)
		# add mirrors & import keys
		sudo sh -c 'echo "deb https://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
		sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
		sudo apt update

		# install
		declare -A ros_mapping
		ros_mapping=(["bionic"]="melodic" ["focal"]="noetic")
		aptInstall ros-${ros_mapping[$(lsb_release -sc)]}-desktop-full

		# setup environment
		if grep -Fxq "source /opt/ros/$(lsb_release -sc)/setup.bash" ~/.bashrc; then
			info "ROS already setup in ~/.bashrc"
		else
			sh -c 'echo "source /opt/ros/$(lsb_release -sc)/setup.bash" >> ~/.bashrc';
		fi
		source ~/.bashrc

		# dependencies and build
		aptInstall "python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential"
		if cmdCheck pip3 -eq 0; then
			aptInstall "python3-pip"
		fi
		sudo pip3 install 6-rosdep
		sudo 6-rosdep
		sudo rosdep init
		rosdep update
		;;
	2)
		# Install ROS 2
		aptInstall "curl gnupg2"
		sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
		sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null'
		sudo apt update

		declare -A ros2_mapping
		ros2_mapping=(["focal"]="foxy" ["jammy"]="humble")
		aptInstall ros-${ros2_mapping[$(lsb_release -sc)]}-desktop
		aptInstall "python3-argcomplete ros-dev-tools"

		# setup environment
		if grep -Fxq "source /opt/ros/$(lsb_release -sc)/setup.bash" ~/.bashrc; then
			info "ROS already setup in ~/.bashrc"
		else
			sh -c 'echo "source /opt/ros/$(lsb_release -sc)/setup.bash" >> ~/.bashrc';
		fi
		;;
	esac
}

publicDevelopmentEnv() {
	case ${1} in
	# Complile and Install Cmake
	1)
		git clone https://github.com/Kitware/CMake ~/CMake
		cd ~/CMake
		./bootstrap
		make -j$(nproc)
		sudo make install
		;;
	# Install Docker
	2)
		# Remove Old Version of Docker
		sudo apt-get remove docker docker-engine docker.io containerd runc
		# Install Dependencies
		aptInstall "ca-certificates curl gnupg"
		# Add Docker's Official GPG Key & Source
		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		sudo chmod a+r /etc/apt/keyrings/docker.gpg
		echo \
			"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
			"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
			sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		# Install Docker Engine
		sudo apt-get update
		aptInstall "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
		;;
	esac
}

asdfDefinitionEnv() {
	# Install asdf
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
	. "$HOME/.asdf/asdf.sh"
	# Install Dependencies
	aptInstall "coreutils"
	# Add asdf plugins
	asdf plugin add cmake https://github.com/asdf-community/asdf-cmake.git
	asdf plugin-add ninja https://github.com/asdf-community/asdf-ninja.git
	asdf plugin add python https://github.com/asdf-community/asdf-python.git
	asdf plugin add pdm https://github.com/1oglop1/asdf-pdm.git
	asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
	asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
	asdf plugin add rust https://github.com/asdf-community/asdf-rust.git
	asdf plugin add java https://github.com/halcyon/asdf-java.git
	# Install package
	asdf install
	# Setup environment
	mkdir $ZSH_CUSTOM/plugins/pdm && pdm completion zsh > $ZSH_CUSTOM/plugins/pdm/_pdm
}

help() {
	echo "Usage: bash bootstrap.sh [type] [target] [options]"
	echo
	echo "TYPE and TARGET"
	echo
	echo "[ros]"
	echo "	ros1: "
	echo "	ros2: "
	echo
	echo "OPTIONS"
	echo
	echo " -v,--Version 	Show version"
	echo " -h,--help 	Show this help message and exit"
}


main() {
	if [ $# -eq 0 ]; then
		welcome
		echo "Usage: bash bootstrap.sh [type] [target] [options]"
		echo
		echo "bootstrap.sh [--help|-h] [--version|-v]"
		echo "	{ros} [target]"
		echo
		cmdCheck curl
		cmdCheck git
	else
		case $@ in
		"ros")
			if [ $(lsb_release -sc) == "jammy" ]; then
				rosDevelopmentEnv 2
			else
				rosDevelopmentEnv 1
			fi
			;;
		"ros ros1")
			rosDevelopmentEnv 1
			;;
		"ros ros2")
			rosDevelopmentEnv 2
			;;
		"terminal")
			terminalEnv 1
			terminalEnv 2
			;;
		"terminal zsh")
			terminalEnv 1
			;;
		"terminal tmux")
			terminalEnv 2
			;;
		"dev")
			asdfDefinitionEnv
			;;
		"docker")
			publicDevelopmentEnv 2
			;;
		--version | -v)
			echo "Version: ${VERSION}"
			;;
		--help | -h)
			help
			;;
		esac
	fi
}

main $@

