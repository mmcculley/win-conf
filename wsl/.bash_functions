# ~/.bash_functions
# showa: to remind yourself of an alias (given some part of it)
showa () { /usr/bin/grep --color=always -i -a1 $@ ~/.aliases | grep -v '^\s*$' | less -FSRXc ; }

# my_ps: List processes owned by my user:
myps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }

# SEARCHING
ff () { /usr/bin/find . -name "$@" ; }      # ff: Find file under the current directory
ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs: Find file whose name starts with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe: Find file whose name ends with a given string

# spotlight: Search for a file using MacOS Spotlight's metadata
spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

# myip: Get my local and external IP address
myip() {
   echo -e "\nExternal IP " ; curl -s http://checkip.dyndns.org/ | sed 's/[a-zA-Z<>/ :]//g'
   echo -e "\nLocal IP " ;ip -o -4 address | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $4}'
}

# ii: display useful host related information
ii() {
    printf "\nYou are logged on ${RED}%s${NC}\n" "$HOST"
    printf "\nAdditional information:${NC}\n" ; uname -a
    printf "\n${RED}Users logged on:${NC}\n" ; w -h
    printf "\n${RED}Current date:${NC}\n" ; date
    printf "\n${RED}Machine stats:${NC}\n" ; uptime
    printf "\n${RED}Current network location:${NC}\n" ; scselect
    printf "\n${RED}Public facing IP Address:${NC}\n" ; myip
    printf "\n"
}

# mcd: Makes new Dir and jumps inside
mcd () { mkdir -p "$1" && cd "$1"; }

# Always list directory contents upon 'cd'
cd() { builtin cd "$@"; ls -la; }

# Aliases for lsd
# Function to check permissions before running lsd
safe_lsd() {
  local opts=()
  local dirs=()
  
  # Separate options from directories
  for arg in "$@"; do
    if [[ "$arg" =~ ^- ]]; then
      opts+=("$arg")
    else
      dirs+=("$arg")
    fi
  done
  
  # Check permissions for directories
  for dir in "${dirs[@]}"; do
    if [ -r "$dir" ]; then
      lsd "${opts[@]}" "$dir"
    else
      echo "Permission denied: $dir"
    fi
  done

  # If no directories specified, list current directory
  if [ ${#dirs[@]} -eq 0 ]; then
    lsd "${opts[@]}"
  fi
}

# better history
function hg() {
    history -10000 | grep -E --color=auto "${@:-}"
}

function docker-clean() {
  docker container prune -f ; 
  docker image prune -f ; 
  docker network prune -f ; 
  docker volume prune -f 
}

# IP address lookup
function whatsmyip () {
    echo "Internal IP: $(hostname -I | awk '{print $1}')"
    echo "External IP: $(curl -s ifconfig.me || echo 'Service unavailable')"
}

# Function to change the chosen ls
changels() {
    local new_ls="$1"
    local init_mode="${ZSH_INIT:-false}"  # Detect initialization

    case $new_ls in
        exa)
            if command -v exa &> /dev/null; then
                alias chosen_ls='exa --icons --octal-permissions --extended --color-scale'
                alias ls_long='chosen_ls -l'
                alias ls_all='chosen_ls -a'
                alias ls_long_all='chosen_ls -al'
                alias ls_wide_all='chosen_ls --across --all --binary'
                alias ls_files_only="find . -maxdepth 1 -type f -exec exa -la --icons --octal-permissions --extended --color-scale {} +"
                alias ls_dirs_only="ls_long_all --only-dirs"
                alias ls_sort_size='ls_long_all --sort=size'
                alias ls_sort_time='ls_long_all --sort=modified'
            else
                echo "exa not found!"
            fi
            
            ;;
        eza)
            if command -v eza &> /dev/null; then
                alias chosen_ls='eza --icons --octal-permissions --extended --color-scale --header'
                alias ls_long='chosen_ls -l'
                alias ls_all='chosen_ls -a'
                alias ls_long_all='chosen_ls -al'
                alias ls_wide_all='chosen_ls --across --all --binary'
                alias ls_files_only="find . -maxdepth 1 -type f -exec eza -la --icons --octal-permissions --extended --color-scale {} +"
                alias ls_dirs_only="ls_long_all --only-dirs"
                alias ls_sort_size='ls_long_all --sort=size'
                alias ls_sort_time='ls_long_all --sort=modified'
            else
                echo "exa not found!"
            fi

            ;;
        lsd)
            if command -v lsd &> /dev/null; then
                alias chosen_ls='safe_lsd --total-size'
                alias ls_long='chosen_ls -l'
                alias ls_all='chosen_ls -a'
                alias ls_long_all='chosen_ls -al'
                alias ls_files_only="find . -maxdepth 1 -type f -exec lsd -l --color=always {} +"
                alias ls_dirs_only="chosen_ls -l --directory-only"
                alias ls_sort_size='ls_long_all --sizesort'
                alias ls_sort_time='ls_long_all --timesort'
            else
                echo "lsd not found!"
            fi
            ;;
        ls)
            alias chosen_ls='/bin/ls --color=auto --human-readable'
            alias ls_long='chosen_ls -l'
            alias ls_all='chosen_ls -a'
            alias ls_long_all='chosen_ls -al'
            alias ls_files_only="ls_long_all | egrep -v '^d'"
            alias ls_wide_all='ls_all -w100'
            alias ls_dirs_only="ls_long_all | egrep '^d'"
            alias ls_sort_size='ls_long_all --sort=size'
            alias ls_sort_time='ls_long_all -t'
            ;;
        *)
            echo "Invalid choice. Use 'exa', 'eza', 'lsd', or 'ls'."
            return 1
            ;;
    esac

    # Update the base 'ls' alias to use the new chosen_ls
    # Only show message if not during initialization
    if [[ "$init_mode" == false ]]; then
        echo "Chosen ls changed to $new_ls"
    fi
    alias ls='chosen_ls'
}
