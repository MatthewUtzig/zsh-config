# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.zshconfig/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh

alias reload="source ~/.zshrc && echo 'Reloaded Zsh Config'"
alias list="ls -lah"
alias takeown="sudo chown -R $USER:$USER ."

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH=/opt/cuda/bin:$PATH

touch ~/tmp/_FilesStoredHereAreNotBackedUp
touch ~/Videos/_FilesStoredHereAreNotBackedUp

alias killdesktop="killall plasmashell"
alias refreshdesktop="killall plasmashell; kstart5 plasmashell"

alias lsgpu="nvidia-smi | sed '/Processes:/q' | head -n -3"

alias vizsh="vim ~/.zshconfig/.zshrc && reload" 

alias extra

extract() {
    # Check if the file is specified
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi

    # Get the file extension
    file="$1"
    extension="${file##*.}"

    # Extract based on file extension
    case "$extension" in
        tar)
            echo "Extracting tar archive..."
            tar -xvf "$file"
            ;;
        tar.gz|tgz)
            echo "Extracting tar.gz archive..."
            tar -xzvf "$file"
            ;;
        tar.bz2|tbz)
            echo "Extracting tar.bz2 archive..."
            tar -xjvf "$file"
            ;;
        tar.xz|txz)
            echo "Extracting tar.xz archive..."
            tar -xJvf "$file"
            ;;
        gz)
            echo "Extracting gzipped file..."
            gunzip "$file"
            ;;
        zip)
            echo "Extracting zip archive..."
            unzip "$file"
            ;;
        rar)
            echo "Extracting rar archive..."
            unrar x "$file"
            ;;
        7z)
            echo "Extracting 7z archive..."
            7z x "$file"
            ;;
        *)
            echo "Unsupported file type: $extension"
            return 1
            ;;
    esac
}


function compress() {
    # Display usage if arguments are missing
    if [[ "$#" -lt 2 ]]; then
        echo "Error: Missing arguments."
        echo "Usage: compress <archive_name> [-n <num_cores>] <source1> [<source2> ...]"
        return 1
    fi

    # Initialize variables
    archive_name=""
    num_cores=""
    sources=()

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -n)
                shift
                if [[ "$#" -gt 0 && "$1" =~ ^[0-9]+$ ]]; then
                    num_cores="$1"
                else
                    echo "Error: Invalid or missing value for -n option."
                    return 1
                fi
                ;;
            -*)
                echo "Error: Unknown option $1"
                return 1
                ;;
            *)
                if [[ -z "$archive_name" ]]; then
                    archive_name="$1"
                else
                    sources+=("$1")
                fi
                ;;
        esac
        shift
    done

    # Ensure archive name and sources are provided
    if [[ -z "$archive_name" || "${#sources[@]}" -eq 0 ]]; then
        echo "Error: Missing archive name or sources."
        echo "Usage: compress <archive_name> [-n <num_cores>] <source1> [<source2> ...]"
        return 1
    fi

    # Determine number of cores to use
    total_cores=$(nproc)
    if [[ -z "$num_cores" ]]; then
        num_cores=$((total_cores / 2))  # Default to half of the cores
    fi

    # Set the XZ_OPT with the number of threads
    export XZ_OPT="-9T$num_cores"

    # Create the tarball
    tar -cvJf "$archive_name" "${sources[@]}"
}


alias catzsh="cat ~/.zshconfig/.zshrc"

alias copy="rsync -avh --progress"
alias sucopy="sudo rsync -avh --progress"





function clone() {
    # Check if two parameters are provided
    if [[ $# -ne 2 ]]; then
        echo "Usage: clone <source> <target>"
        return 1
    fi

    # Assign parameters to source and target
    local source="$1"
    local target="$2"

    # Run sudo dd with status=progress
    sudo dd if="$source" of="$target" bs=4M status=progress
}

alias del="rm -rf"

function updatezsh() {
    cd $HOME/.zshconfig
    git pull --recurse-submodules
    cd -
}

if grep -q '^ID=arch' /etc/os-release; then
	function updateyay() {
		echo "Updating/Installing yay"
		del $HOME/tmp/yay
		git clone https://aur.archlinux.org/yay.git $HOME/tmp/yay
                cd $HOME/tmp/yat
		makepkg -si
		cd -
	}	
fi	

function status() {
  if [[ -z "$1" ]]; then
    echo "Usage: status <service_name>"
    return 1
  fi

  local service="$1"
#
#  # Validate service name with systemctl
#  if ! systemctl list-units --type=service | grep -q "^$service"; then
#    echo "Error: '$service' is not a valid service."
#    return 1
#  fi

  # Display service status and logs
  echo "\n--- Last 256 lines of logs for $service ---"
  sudo journalctl -u "$service" -n 256 --no-pager

  sudo systemctl status "$service" --lines=0

}


function restart() {
  if [[ -z "$1" ]]; then
    echo "Usage: restart <service_name>"
    return 1
  fi

  local service="$1"

  # Validate service name with systemctl
  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Restart the service
  echo "Restarting service: $service"
  sudo systemctl restart "$service"

  # Check the restart status
  if [[ $? -eq 0 ]]; then
    echo "Service '$service' restarted successfully."
  else
    echo "Failed to restart service '$service'."
    return 1
  fi
}

function start() {
  if [[ -z "$1" ]]; then
    echo "Usage: start <service_name>"
    return 1
  fi

  local service="$1"

  # Validate service name with systemctl
  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Start the service
  echo "Starting service: $service"
  sudo systemctl start "$service"

  # Check the start status
  if [[ $? -eq 0 ]]; then
    echo "Service '$service' started successfully."
  else
    echo "Failed to start service '$service'."
    return 1
  fi
}


# Define the stop function
function stop() {
  if [[ -z "$1" ]]; then
    echo "Usage: stop <service_name>"
    return 1
  fi

  local service="$1"

  # Validate service name with systemctl
  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Stop the service
  echo "Stopping service: $service"
  sudo systemctl stop "$service"

  # Check the stop status
  if [[ $? -eq 0 ]]; then
    echo "Service '$service' stopped successfully."
  else
    echo "Failed to stop service '$service'."
    return 1
  fi
}


# Define the enable function
function enable() {
  # Check if no arguments are provided
  if [[ -z "$1" ]]; then
    echo "Usage: enable [-n] <service_name>"
    return 1
  fi

  # Parse arguments
  local start_now=false
  local service=""

  if [[ "$1" == "-n" ]]; then
    start_now=true
    service="$2"
  else
    service="$1"
  fi

  # Validate service name with systemctl
  if [[ -z "$service" ]]; then
    echo "Error: No service specified."
    return 1
  fi

  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Enable the service
  echo "Enabling service: $service"
  sudo systemctl enable "$service"

  if [[ $? -eq 0 ]]; then
    echo "Service '$service' enabled successfully."
  else
    echo "Failed to enable service '$service'."
    return 1
  fi

  # Optionally start the service now
  if [[ "$start_now" == true ]]; then
    echo "Starting service: $service"
    sudo systemctl start "$service"

    if [[ $? -eq 0 ]]; then
      echo "Service '$service' started successfully."
    else
      echo "Failed to start service '$service'."
      return 1
    fi
  fi
}


# Define the disable function
function disable() {
  # Check if no arguments are provided
  if [[ -z "$1" ]]; then
    echo "Usage: disable [-n] <service_name>"
    return 1
  fi

  # Parse arguments
  local stop_now=false
  local service=""

  if [[ "$1" == "-n" ]]; then
    stop_now=true
    service="$2"
  else
    service="$1"
  fi

  # Validate service name with systemctl
  if [[ -z "$service" ]]; then
    echo "Error: No service specified."
    return 1
  fi

  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Disable the service
  echo "Disabling service: $service"
  sudo systemctl disable "$service"

  if [[ $? -eq 0 ]]; then
    echo "Service '$service' disabled successfully."
  else
    echo "Failed to disable service '$service'."
    return 1
  fi

  # Optionally stop the service now
  if [[ "$stop_now" == true ]]; then
    echo "Stopping service: $service"
    sudo systemctl stop "$service"

    if [[ $? -eq 0 ]]; then
      echo "Service '$service' stopped successfully."
    else
      echo "Failed to stop service '$service'."
      return 1
    fi
  fi
}

# Define the follow function
function follow() {
  # Check if no arguments are provided
  if [[ -z "$1" ]]; then
    echo "Usage: follow <service_name>"
    return 1
  fi

  local service="$1"

  # Validate service name with systemctl
  if ! systemctl list-units --type=service | grep -q "^$service"; then
    echo "Error: '$service' is not a valid service."
    return 1
  fi

  # Follow the service logs
  echo "Following logs for service: $service (Press Ctrl+C to stop)"
  sudo journalctl -u "$service" -f --no-pager
}


function is_arch_linux() {
  # Check if the system is Arch Linux
  if grep -q '^ID=arch' /etc/os-release 2>/dev/null; then
    return 1
  else
    return 0
  fi
}



function is_yay_installed() {
  if command -v yay &>/dev/null; then
    return 0
  else
    return 1
  fi
}


function safeupdate() {
  # Function to check if a mount point is mounted
  is_mounted() {
    mount | grep -q " on $1 "
  }

  # Check if /boot is mounted
  if ! is_mounted "/boot"; then
    echo "Error: /boot is not mounted. Please mount /boot and try again."
    return 1
  fi

  # Check if /efi is mounted
  if ! is_mounted "/boot/efi"; then
    echo "Error: /boot/efi is not mounted. Please mount /boot/efi and try again."
    return 1
  fi

  # Determine package manager and perform update
  if command -v pacman &>/dev/null; then
    echo "Detected Arch-based system. Performing system update with pacman..."
    sudo pacman -Syu

    # Run yay if available
    if command -v yay &>/dev/null; then
      echo "yay detected. Performing AUR updates..."
      yay -Syu
    else
      echo "yay not found. Skipping AUR updates."
    fi

  elif command -v apt &>/dev/null; then
    echo "Detected Debian-based system. Performing full system update..."
    sudo apt update && sudo apt full-upgrade -y
  else
    echo "Error: No supported package manager found. Please install pacman or apt."
    return 1
  fi

  echo "System update completed successfully."
}

function install() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: install <package1> [package2 ... packageN]"
    return 1
  fi

  if command -v yay &>/dev/null; then
    echo "Detected yay. Using yay to install packages."
    yay -S --needed "$@"
  elif command -v pacman &>/dev/null; then
    echo "yay not found. Falling back to pacman."
    sudo pacman -S --needed "$@"
  elif command -v apt-get &>/dev/null; then
    echo "Detected Debian-based system. Using apt-get to install packages."
    sudo apt-get install -y "$@"
  else
    echo "Error: No supported package manager found. Please install yay, pacman, or apt-get."
    return 1
  fi
}

function hist() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: hist <search_term>"
    return 1
  fi

  history | grep -i -B 5 -A 5 "$1"
}

function zpool-replace() {
  if [[ $# -ne 3 ]]; then
    echo "Usage: zpool-replace <pool_name> <guid> <device>"
    return 1
  fi

  local pool_name="$1"
  local guid="$2"
  local device="$3"

  echo "Clearing ZFS label on $device..."
  sudo zpool labelclear -f "$device"


  echo "Replacing device in ZFS pool $pool_name..."
  sudo zpool replace "$pool_name" "$guid" "$device"
  if [[ $? -eq 0 ]]; then
    echo "Device replacement for pool $pool_name completed successfully."
  else
    echo "Failed to replace device in pool $pool_name."
    return 1
  fi
}


function zpool-import() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: zpool-import-crypt [-R <alt_root>] <pool_name>"
    return 1
  fi

  local alt_root=""
  local pool_name=""

  # Parse arguments
  if [[ "$1" == "-R" ]]; then
    if [[ -z "$2" ]]; then
      echo "Error: -R requires an argument."
      return 1
    fi
    alt_root="$2"
    pool_name="$3"
  else
    pool_name="$1"
  fi

  if [[ -z "$pool_name" ]]; then
    echo "Error: No pool name specified."
    return 1
  fi

  # Check if the pool is already imported
  if zpool list "$pool_name" &>/dev/null; then
    echo "Pool '$pool_name' is already imported. Skipping import step."
  else
    # Import the pool
    if [[ -n "$alt_root" ]]; then
      echo "Importing pool '$pool_name' with alternate root '$alt_root'..."
      sudo zpool import -R "$alt_root" "$pool_name"
    else
      echo "Importing pool '$pool_name'..."
      sudo zpool import "$pool_name"
    fi

    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to import pool '$pool_name'."
      return 1
    fi
  fi

  # Load the encryption key
  echo "Loading encryption key for pool '$pool_name'..."
  sudo zfs load-key "$pool_name"

  # Mount the pool recursively
  echo "Mounting pool '$pool_name' recursively..."
  sudo zfs mount -R "$pool_name"

  if [[ $? -eq 0 ]]; then
    echo "Pool '$pool_name' imported (if needed), key loaded, and mounted successfully."
  else
    echo "Error: Failed to mount pool '$pool_name'."
    return 1
  fi
}

alias cdzsh="cd ~/.zshconfig"

# Add ~/.zshconfig/scripts to PATH if not present
if [[ ":$PATH:" != *":$HOME/.zshconfig/scripts:"* ]]; then
  PATH="$HOME/.zshconfig/scripts:$PATH"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.zshconfig/.p10k.zsh ]] || source ~/.zshconfig/.p10k.zsh
