#!/bin/bash

FOLDER_PATH="$HOME/.pandoc/templates/"

LETTER_TEMPLATE="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/letter-din5008/letter.latex?token=GHSAT0AAAAAAB77JDDYINXJNFBLEQNLJBRMZCUB4YQ"

# Create template directory if they don't exist
create_template_directory(){
    if [ -d "$FOLDER_PATH" ]; then
        echo "Template directory already exists"
    else
        echo "Create $FOLDER_PATH"
        mkdir -p $FOLDER_PATH
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
    if [ -e $FOLDER_PATH/letter.latex ]; then
        # curl -L $LETTER_TEMPLATE -o "$FOLDER_PATH/letter.txt"
        echo "exists"
    else
        echo "nicht da"
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
else
    echo "$1: invalid option"
    echo "Try '--help' for more information."
    exit 1
fi
