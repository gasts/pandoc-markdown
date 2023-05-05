#!/bin/bash

SYS_TEMPLTE_PATH="$HOME/.pandoc/templates/"

LETTER_TEMPLATE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/templates/letter-din5008/letter.latex?token=GHSAT0AAAAAAB77JDDYINXJNFBLEQNLJBRMZCUB4YQ"
LETTER_TEMPLATE_NAME="letter.latex"
LETTER_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/letter-din5008/letter-minimal/letter.md?token=GHSAT0AAAAAACBVW7FYRRHQPLM63ZQIZG22ZCVBZIA"
INVOICE_EXAMPLE_GIT="https://raw.githubusercontent.com/gasts/pandoc-markdown/main/examples/letter-din5008/letter-invoice/letter.md?token=GHSAT0AAAAAACBVW7FZ3ECI6PGP75HIPZHOZCVCNUQ"

EISVOGEL_TEMPLATE_GIT=""
EISVOGEL_TEMPLATE_NAME="eisvogel.latex"
EISVOGEL_EXAMPLE_GIT=""

DEFAULT_TEMPLATE_GIT=""
DEFAULT_TEMPLATE_NAME="default.latex"
DEFAULT_EXAMPLE_GIT=""

FORMAT="%-30s %s\n"

# Create template directory if they don't exist
create_template_directory(){
    if [ -d "$SYS_TEMPLTE_PATH" ]; then
        echo "Template directory already exists"
    else
        echo "Create $SYS_TEMPLTE_PATH"
        mkdir -p $SYS_TEMPLTE_PATH
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
    curl -O $LETTER_TEMPLATE_GIT
    curl -O $EISVOGEL_TEMPLATE_GIT
    curl -O $DEFAULT_TEMPLATE_GIT
}

# Parse command line arguments
if [ "$1" == "--install" ]; then
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
    # Check if template directory exists
    create_template_directory
    # Install templates
    install_update_templates
elif [ "$1" == "--new" ]; then
    echo "Creating file and folder structur"
    echo "Create assets directory"
    mkdir assets
    if [ -n "$2" ] && [ "$2" == "letter" ]; then
        echo "Create letter.md template"
        curl -O $LETTER_EXAMPLE_GIT
    elif [ -n "$2" ] && [ "$2" == "eisvogel" ]; then
        echo "Create eisvogel template"
        curl -O $EISVOGEL_EXAMPLE_GIT
    else
        echo "Create default template";
        curl -O $DEFAULT_EXAMPLE_GIT
    fi
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo ""
    echo "Usage:"
    printf "${FORMAT}" "sdoc --install" "install requirements"
    printf "${FORMAT}" "sdoc --new" "create default project"
    printf "${FORMAT}" "sdoc --new <typ>" "typ is letter, invoice or eisvogel"
else
    echo "$1: invalid option"
    echo "Try '--help' for more information."
    exit 1
fi
