#!/bin/bash

TEMPLTE_FOLDER_PATH="$HOME/.pandoc/templates/"

GIT_LETTER_TEMPLATE="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/letter-din5008/letter.latex?token=GHSAT0AAAAAAB77JDDYINXJNFBLEQNLJBRMZCUB4YQ"
LETTER_FILE_NAME="letter.latex"

# Create template directory if they don't exist
create_template_directory(){
    if [ -d "$TEMPLTE_FOLDER_PATH" ]; then
        echo "Template directory already exists"
    else
        echo "Create $TEMPLTE_FOLDER_PATH"
        mkdir -p $TEMPLTE_FOLDER_PATH
    fi
}

# Function to check if a pip package is installed
is_package_installed() {
    if pip3 show $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if pip is installed
is_pip_installed() {
    if which pip &> /dev/null; then
        return 0
    else
        echo "Error: Package 'pip' is missing. Please install it and restart the installation process."
        return 1
    fi
}

# Update 
install_update_templates(){
    echo "Download and Install template files"
    if [ -e $TEMPLTE_FOLDER_PATH/$LETTER_FILE_NAME ]; then
        # backup last old file
        mv $TEMPLTE_FOLDER_PATH/$LETTER_FILE_NAME $TEMPLTE_FOLDER_PATH/$LETTER_FILE_NAME.bak
        curl -L $GIT_LETTER_TEMPLATE -o "$TEMPLTE_FOLDER_PATH/$LETTER_FILE_NAME"
    else
        curl -L $GIT_LETTER_TEMPLATE -o "$TEMPLTE_FOLDER_PATH/$LETTER_FILE_NAME"
    fi
}

# Parse command line arguments
if [ "$1" == "--install" ]; then
    # Check if requirements are installed
    if is_pip_installed; then
        if is_package_installed "pandoc-latex-environment"; then
            echo "pandoc-latex-environment is already installed"
        else
            # Install the package
            echo "Installing pandoc-latex-environment..."
            pip3 install pandoc-latex-environment
        fi
    fi
    # Check if template directory exists
    create_template_directory
    # Install templates
    install_update_templates
elif [ "$1" == "--new" ]; then
    echo "Creating file and folder structur"
    mkdir assets
    if [ -n "$2" ] && [ "$2" == "letter" ]; then
        echo "Create letter template"

    elif [ -n "$2" ] && [ "$2" == "eisvogel" ]; then
        echo "Create eisvogel template"
        
    else
        echo "Create default template";

else
    echo "$1: invalid option"
    echo "Try '--help' for more information."
    exit 1
fi
