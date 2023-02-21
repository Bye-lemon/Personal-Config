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
success() {
	msg "${Green}[✔]${Color_off} ${1}${2}"
}

# check and install
cmdCheck() {
	if ! hash $1 &>/dev/null; then
		error "Command [${1}] not found"
		return 1
	fi
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

rosDevelopmentEnv() {
	case ${1} in
	# Install ROS
	1)
		# add mirrors & import keys
		sudo sh -c 'echo "deb https://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
		sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
		sudo apt update

		# install
		sudo apt-get -y install ros-melodic-desktop-full

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
		error "Not support ROS 2"
		;;
	esac
}

help() {
	echo "Usage: bash bootstrap.sh [type] [target] [options]"
	echo
	echo "TYPE and TARGET"
	echo
	echo "[ros]"
	echo "	ros1: a delightful, open source, community-driven framework for managing your Zsh configuration."
	echo "	ros2: Configure ~/.zshrc: Powerlevel10k;Plugins:extract/sudo/zsh-syntax-highlighting/z"
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
			rosDevelopmentEnv 1
			;;
		"ros ros1")
			rosDevelopmentEnv 1
			;;
		"ros ros2")
			rosDevelopmentEnv 2
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

