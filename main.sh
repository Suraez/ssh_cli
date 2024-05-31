# Function to display the list of servers
ssh_cli_list() {
    # Get the list of server aliases from the SSH config file
    local servers=$(awk '/^Host / {print $2}' ~/.ssh/config)

    # Check if there are any servers configured
    if [ -z "$servers" ]; then
        echo "No servers found in SSH config."
        return 1
    fi

    # Display the list of servers with numbers
    local i=1
    for server in $servers; do
        echo "$i) $server"
        ((i++))
    done
}

# Function to connect to a selected server
ssh_cli_connect() {
    # Display the list of servers
    ssh_cli_list

    # Prompt the user to select a server
    read -p "Enter the number of the server to connect to: " choice

    # Validate the user's choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number."
        return 1
    fi

    # Get the selected server alias
    local servers=$(awk '/^Host / {print $2}' ~/.ssh/config)
    local server_array=($servers)
    local num_servers=${#server_array[@]}

    if (( choice < 1 || choice > num_servers )); then
        echo "Invalid selection. Please enter a number between 1 and $num_servers."
        return 1
    fi

    local selected_server=${server_array[choice - 1]}

    # Connect to the selected server
    ssh $selected_server
}

# Function to add a server to the SSH config file
ssh_cli_add() {
    read -p "Enter the server alias: " alias
    read -p "Enter the hostname or IP address: " hostname
    read -p "Enter the username: " username

    # Check if all required parameters are provided
    if [ -z "$alias" ] || [ -z "$hostname" ] || [ -z "$username" ]; then
        echo "All fields are required."
        return 1
    fi

    # Check if the SSH config file exists, create it if it doesn't
    local ssh_config="$HOME/.ssh/config"
    if [ ! -f "$ssh_config" ]; then
        touch "$ssh_config"
        chmod 600 "$ssh_config"
        echo "# SSH Config File" >> "$ssh_config"
        echo "" >> "$ssh_config"
    fi

    # Append server details to the SSH config file
    echo "Host $alias" >> "$ssh_config"
    echo "    HostName $hostname" >> "$ssh_config"
    echo "    User $username" >> "$ssh_config"

    echo "Server '$alias' added to SSH config file."
}

# Function to handle different actions
ssh_cli() {
    local action="$1"

    case "$action" in
        list)
            ssh_cli_list
            ;;
        connect)
            ssh_cli_connect
            ;;
        add)
            ssh_cli_add
            ;;
        *)
            echo "Usage: ssh_cli <list|connect|add>"
            return 1
            ;;
    esac
}
