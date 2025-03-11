#!/bin/bash

xhost +local:docker
source ./config.env

# Color definitions
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

info() { echo "${BLUE}[INFO]${RESET} $1"; }
success() { echo "${GREEN}[SUCCESS]${RESET} $1"; }
warning() { echo "${YELLOW}[WARNING]${RESET} $1"; }
error() { echo "${RED}[ERROR]${RESET} $1"; }

# Check arguments
AUTO_MODE=false
if [[ "$1" == "auto" ]]; then
	AUTO_MODE=true
	info "Auto mode enabled."
fi

image_exists() {
	if docker images | grep -q "^$IMAGE_NAME "; then
		success "Image '$IMAGE_NAME' exists."
		return 0
	else
		warning "Image '$IMAGE_NAME' does not exist."
		return 1
	fi
}

build_image() {
	info "Building the Docker image '$IMAGE_NAME'..."
	if docker build -t $IMAGE_NAME .; then
		success "Image '$IMAGE_NAME' built successfully."
	else
		error "Failed to build the Docker image."
		exit 1
	fi
}

create_container() {
	if ! image_exists; then
		build_image
	fi
	info "Container not found, creating it ..."

	# Parse SHARED_PATHS variable and expand ${HOME}
	IFS=',' read -ra paths <<<"$(eval echo $SHARED_PATHS)"
	local mount_flags=""
	for path in "${paths[@]}"; do
		expanded_path=$(eval echo "$path")
		if [ -d "$expanded_path" ]; then
			mount_flags+=" --mount type=bind,source=$expanded_path,target=/home/$USER_NAME/$(basename $expanded_path)"
			success "Mounting shared path: $expanded_path"
		else
			warning "Path $expanded_path does not exist. Skipping mount."
		fi
	done

	docker run -it \
		--device=/dev/input/js0 \
		--group-add $(getent group input | cut -d: -f3) \
		--name $CONTAINER_NAME \
		--privileged \
		$mount_flags \
		--env DISPLAY=$DISPLAY \
		--volume $X11_SOCKET:$X11_SOCKET \
		--network $NETWORK \
		$(for port in $PORTS; do echo -p $port; done) \
		$IMAGE_NAME
}

start_container() {
	if [ "$(docker ps -qaf name=$CONTAINER_NAME)" = "" ]; then
		warning "Container '$CONTAINER_NAME' does not exist."
		if $AUTO_MODE; then
			create_container
		else
			if (whiptail --title "Container Not Found" --yesno "The container '$CONTAINER_NAME' does not exist. Do you want to create it?" 10 60); then
				create_container
			else
				info "Returning to main menu."
				return
			fi
		fi
	else
		info "Starting container '$CONTAINER_NAME'..."
		if ! docker start $CONTAINER_NAME >/dev/null; then
			error "Error while starting the container."
			exit 1
		fi
		success "Container '$CONTAINER_NAME' started."

		if $AUTO_MODE; then
			connect_to_container
		else
			if (whiptail --title "Container started" --yesno "The container is started successfully. Do you want to connect to it?" 10 60); then
				connect_to_container
			else
				info "Returning to main menu."
			fi
		fi
	fi
}

connect_to_container() {
	if [ "$(docker ps -qf name=$CONTAINER_NAME)" = "" ]; then
		warning "Container '$CONTAINER_NAME' is not running."
		if $AUTO_MODE; then
			start_container
		else
			if (whiptail --title "Container Not Running" --yesno "The container is not running. Do you want to start it?" 10 60); then
				start_container
			else
				info "Returning to main menu."
			fi
		fi
	fi
	info "Connecting to container..."
	docker exec -it $CONTAINER_NAME zsh --login
}

stop_container() {
	info "Stopping container '$CONTAINER_NAME'..."
	if docker stop $CONTAINER_NAME >/dev/null; then
		success "Container '$CONTAINER_NAME' stopped."
	else
		error "Failed to stop the container."
	fi
}

# Handle Auto Mode
if $AUTO_MODE; then
	start_container
	exit 0
fi

# GUI Menu using `whiptail`
main_menu() {
	local choice
	choice=$(whiptail --title "Docker Container Manager" --menu "Choose an action:" 15 60 5 \
		"1" "Start or Create Container" \
		"2" "Restart Container" \
		"3" "Stop Container" \
		"4" "Connect to Container" \
		"5" "Exit" 3>&1 1>&2 2>&3)

	case $choice in
	1)
		start_container
		;;
	2)
		stop_container
		start_container
		;;
	3)
		stop_container
		;;
	4)
		connect_to_container
		;;
	5)
		info "Exiting the script."
		exit 0
		;;
	*)
		error "Invalid option selected."
		;;
	esac
}

# Check dependencies
if ! command -v whiptail &>/dev/null; then
	error "The 'whiptail' utility is not installed. Install it with 'sudo apt install whiptail' and rerun the script."
	exit 1
fi

# Main loop
while true; do
	main_menu
done
