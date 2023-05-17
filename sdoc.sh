#!/bin/bash

LOCK_FILE=/tmp/sdoc.lock

SYS_TEMPLTE_PATH="$HOME/.pandoc/templates"
SYS_SCRIPT_PATH="$HOME/.local/sdoc"

LETTER_TEMPLATE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/letter-din5008/letter.latex"
LETTER_TEMPLATE_NAME="letter.latex"
LETTER_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/letter-din5008/letter-minimal/letter.md"
LETTER_EXAMPLE_NAME="letter.md"
INVOICE_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/letter-din5008/letter-invoice/letter.md"
INVOICE_EXAMPLE_NAME="invoice.md"

EISVOGEL_TEMPLATE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/eisvogel/eisvogel.latex"
EISVOGEL_TEMPLATE_NAME="eisvogel.latex"
EISVOGEL_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/eisvogel/document.md"
EISVOGEL_EXAMPLE_NAME="report.md"

DEFAULT_TEMPLATE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/default/default.latex"
DEFAULT_TEMPLATE_NAME="default.latex"
DEFAULT_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/default/document.md"
DEFAULT_EXAMPLE_NAME="document.md"

FORMAT="%-30s %s\n"

is_inotify_installed() {
    if [ -z "$(which inotifywait)" ]; then
        echo "inotifywait not installed."
        echo "In most distros, it is available in the inotify-tools package."
        echo "Please install and try again."
        exit 1
    fi
}

# Create directory if they don't exist
create_directory(){
    local path="$1"
    if [ -d "$1" ]; then
        echo "Directory $1 already exists"
    else
        echo "Create $1"
        mkdir -p $1
    fi
}

# Function to check if a pip package is installed
is_pip_package_installed() {
    if pip3 show $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if python pip is installed
is_pip_installed() {
    if which pip &> /dev/null; then
        return 0
    else
        echo "Error: Package 'pip' is missing. Please install it and restart the installation process."
        return 1
    fi
}

# Function to copy script to $home/.local/sdoc
copy_script_to_local(){
    local script_path="$(realpath $0)"
    local target_path="$HOME/.local/sdoc/$(basename $0)"
    create_directory $SYS_SCRIPT_PATH
    echo "Copying script from $script_path to $target_path"
    cp "$script_path" "$target_path"
}

# Function to check template type
get_template_type() {
    file_path="$1"
    template_type="default"
    counter=1
    while IFS= read -r row
    do
        if [[ $row == template* ]]; then
            template_type="${row#*: }"
            template_type=${template_type%\"}
            template_type=${template_type#\"}
            break
        fi
        if [[ $counter -eq 5 ]]; then
            break
        fi
        ((counter++))
    done < "$file_path"
    echo "$template_type"
}

# Function create bash alias
create_bash_alias(){
    local bashrc_file="$HOME/.bashrc"
    local entry="alias sdoc=$SYS_SCRIPT_PATH/$(basename $0)"
    # exist alias?
    if grep -q "$entry" "$bashrc_file"; then
        echo "Entry '$entry' already exists in $bashrc_file"
    else
        echo "Adding entry '$entry' to $bashrc_file"
        echo "$entry" >> "$bashrc_file"
        source "$bashrc_file"
    fi
}

# install or update templates 
install_update_templates(){
    echo "Install or update template files"
    # letter template
    if [ -e $SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME ]; then
        echo "Backup $SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME to $SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME.bak"
        mv $SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME $SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME.bak
    fi
    # eisvogel template
    if [ -e $SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_GIT ]; then
        echo "Backup $SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_NAME to $SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_NAME.bak"
        mv $SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_NAME $SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_NAME.bak
    fi
    # default template
    if [ -e $SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME ]; then
        echo "Backup $SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME to $SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME.bak"
        mv $SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME $SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME.bak
    fi
    echo "Download $LETTER_TEMPLATE_NAME"
    curl -L $LETTER_TEMPLATE_GIT -o "$SYS_TEMPLTE_PATH/$LETTER_TEMPLATE_NAME"
    echo "Download $EISVOGEL_TEMPLATE_NAME"
    curl -L $EISVOGEL_TEMPLATE_GIT -o "$SYS_TEMPLTE_PATH/$EISVOGEL_TEMPLATE_NAME"
    echo "Download $DEFAULT_TEMPLATE_NAME"
    curl -L $DEFAULT_TEMPLATE_GIT -o "$SYS_TEMPLTE_PATH/$DEFAULT_TEMPLATE_NAME"
    
    echo "Download $DEFAULT_EXAMPLE_NAME"
    curl -L $DEFAULT_EXAMPLE_GIT -o "$SYS_SCRIPT_PATH/$DEFAULT_EXAMPLE_NAME"
    echo "Download $EISVOGEL_EXAMPLE_NAME";
    curl -L $EISVOGEL_EXAMPLE_GIT -o "$SYS_SCRIPT_PATH/$EISVOGEL_EXAMPLE_NAME"
    echo "Download $LETTER_EXAMPLE_NAME"
    curl -L $LETTER_EXAMPLE_GIT -o "$SYS_SCRIPT_PATH/$LETTER_EXAMPLE_NAME"
    echo "Download $INVOICE_EXAMPLE_NAME"
    curl -L $INVOICE_EXAMPLE_GIT -o "$SYS_SCRIPT_PATH/$INVOICE_EXAMPLE_NAME"
}

# ###
# Parse command line arguments
# ###
if [ "$1" == "--install" ] || [ "$1" == "-i" ]; then
    # Check if requirements are installed
    if is_pip_installed; then
        if is_pip_package_installed "pandoc-latex-environment"; then
            echo "pandoc-latex-environment is already installed"
        else
            # Install the package
            echo "Installing pandoc-latex-environment..."
            pip3 install pandoc-latex-environment
        fi
    fi
    # Check if directorys exists
    create_directory $SYS_TEMPLTE_PATH/
    create_directory $SYS_SCRIPT_PATH/
    # Install templates
    install_update_templates
    # copy script to .local
    copy_script_to_local
    # create bashrc alias
    create_bash_alias

elif [ "$1" == "--new" ] || [ "$1" == "-n" ]; then
    echo "Create new project structur"
    mkdir assets
    if [ -n "$2" ] && [ "$2" == "letter" ]; then
        echo "Create letter.md template"
        cp $SYS_SCRIPT_PATH/$LETTER_EXAMPLE_NAME .
    elif [ -n "$2" ] && [ "$2" == "invoice" ]; then
        echo "Create invoice.md template"
        cp $SYS_SCRIPT_PATH/$INVOICE_EXAMPLE_NAME .
    elif [ -n "$2" ] && [ "$2" == "eisvogel" ]; then
        echo "Create report.md template"
        cp $SYS_SCRIPT_PATH/$EISVOGEL_EXAMPLE_NAME .
    else
        echo "Create default.md template";
        cp $SYS_SCRIPT_PATH/$DEFAULT_EXAMPLE_NAME .
    fi

elif [ "$1" == "--update" ] || [ "$1" == "-u" ]; then
    install_update_templates

elif [ "$1" == "--watch" ] || [ "$1" == "-w" ]; then
    is_inotify_installed
    # delete old lock file
    rm "${LOCK_FILE}"
    # watcher for saved *.md files
    inotifywait --monitor --format "%f" --event modify ./ \
    | while read changed; do
        if [[ "${changed##*.}" == "md" ]]; then
            if [ -e "${LOCK_FILE}" ] && kill -0 $(cat "${LOCK_FILE}") 2> /dev/null; then
                echo "Script ist current runnung"
            else
                # create lock file
                echo $$ > "${LOCK_FILE}"
                # execute pandoc command
                filename=''
                if [ -n $2 ]; then
                    if [ -f $2 ]; then
                        filename=$(basename -- "$2")
                    else
                        echo "File: $2 not found"
                        rm "${LOCK_FILE}"
                        exit 1
                    fi
                else
                    filename=$(basename -- "$changed")
                fi
                filename="${filename%.*}"
                echo "EIN TEST: $filename"
                template_typ=$(get_template_type "$filename.md")
                echo "Document build as $filename.pdf"
                if [ "$template_typ" = "letter" ]; then
                    pandoc $filename.md -o $filename.pdf --template=$template_typ
                elif [ "$template_typ" = "eisvogel" ]; then
                    echo "..."
                else
                    pandoc $filename.md -o $filename.pdf --template=$template_typ --filter pandoc-latex-environment --resource-path=./assets/ --listings
                fi
                
                sleep 4
                # delete lock file
                rm "${LOCK_FILE}"
            fi
        fi
    done
    

elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo ""
    echo "Usage:"
    printf "${FORMAT}" "sdoc -i, --install" "install project requirements"
    printf "${FORMAT}" "sdoc -n, --new" "create default project"
    printf "${FORMAT}" "sdoc -n, --new <typ>" "typ is default, letter, invoice or eisvogel"
    printf "${FORMAT}" "sdoc -u, --update" "update templates"
    printf "${FORMAT}" "sdoc -w, --watch" "Watch for changes and build"
    printf "${FORMAT}" "sdoc -w, --watch <file>" "Watch for changes and build <file>"
    printf "${FORMAT}" "sdoc -nw" "compination --new and --watch"
    printf "${FORMAT}" "sdoc -nw <file>" "compination --new and --watch <file>"

else
    echo "$1: invalid option"
    echo "Try '--help' or '-h' for more information."
    exit 1
fi