#!/bin/bash

LOCK_FILE=/tmp/sdoc.lock

SYS_TEMPLATE_PATH="$HOME/.pandoc/templates"
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

# Überprüft, ob inotifywait installiert ist
is_inotify_installed() {
    if ! command -v inotifywait &>/dev/null; then
        echo "inotifywait is not installed."
        echo "Please install 'inotify-tools' package in your distribution."
        echo "Then, try again."
        exit 1
    fi
}

# Erstellt ein Verzeichnis, falls es nicht existiert
create_directory() {
    local path="$1"
    if [ -d "$1" ]; then
        echo "Directory $1 already exists."
    else
        echo "Creating directory $1"
        mkdir -p "$1"
    fi
}

# Überprüft, ob ein pip-Paket installiert ist
is_pip_package_installed() {
    if pip3 show "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Überprüft, ob Python pip installiert ist
is_pip_installed() {
    if ! command -v pip &>/dev/null; then
        echo "Error: Package 'pip' is missing. Please install it and restart the installation process."
        return 1
    fi
}

# Kopiert das Skript nach $HOME/.local/sdoc
copy_script_to_local() {
    local script_path="$(realpath "$0")"
    local target_path="$HOME/.local/sdoc/$(basename "$0")"
    create_directory "$SYS_SCRIPT_PATH"
    echo "Copying script from $script_path to $target_path"
    cp "$script_path" "$target_path"
}

# Überprüft den Vorlagentyp
get_template_type() {
    local file_path="$1"
    local template_type="default"
    local counter=1
    while IFS= read -r row && [ "$counter" -le 5 ]; do
        if [[ $row == template* ]]; then
            template_type="${row#*: }"
            template_type=${template_type%\"}
            template_type=${template_type#\"}
            break
        fi
        ((counter++))
    done <"$file_path"
    echo "$template_type"
}

# Erstellt einen Bash-Alias
create_bash_alias() {
    local bashrc_file="$HOME/.bashrc"
    local entry="alias sdoc=$SYS_SCRIPT_PATH/$(basename "$0")"
    # Existiert bereits ein Alias?
    if grep -q "$entry" "$bashrc_file"; then
        echo "Entry '$entry' already exists in $bashrc_file"
    else
        echo "Adding entry '$entry' to $bashrc_file"
        echo "$entry" >>"$bashrc_file"
        source "$bashrc_file"
    fi
}

# Installiert oder aktualisiert die Vorlagen
install_update_templates() {
    echo "Installing or updating template files"
    # Letter Template
    if [ -e "$SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME" ]; then
        echo "Backing up $SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME to $SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME.bak"
        mv "$SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME" "$SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME.bak"
    fi
    # Eisvogel Template
    if [ -e "$SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME" ]; then
        echo "Backing up $SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME to $SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME.bak"
        mv "$SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME" "$SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME.bak"
    fi
    # Default Template
    if [ -e "$SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME" ]; then
        echo "Backing up $SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME to $SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME.bak"
        mv "$SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME" "$SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME.bak"
    fi

    echo "Downloading $LETTER_TEMPLATE_NAME"
    curl -L "$LETTER_TEMPLATE_GIT" -o "$SYS_TEMPLATE_PATH/$LETTER_TEMPLATE_NAME"
    echo "Downloading $EISVOGEL_TEMPLATE_NAME"
    curl -L "$EISVOGEL_TEMPLATE_GIT" -o "$SYS_TEMPLATE_PATH/$EISVOGEL_TEMPLATE_NAME"
    echo "Downloading $DEFAULT_TEMPLATE_NAME"
    curl -L "$DEFAULT_TEMPLATE_GIT" -o "$SYS_TEMPLATE_PATH/$DEFAULT_TEMPLATE_NAME"

    echo "Downloading $DEFAULT_EXAMPLE_NAME"
    curl -L "$DEFAULT_EXAMPLE_GIT" -o "$SYS_SCRIPT_PATH/$DEFAULT_EXAMPLE_NAME"
    echo "Downloading $EISVOGEL_EXAMPLE_NAME"
    curl -L "$EISVOGEL_EXAMPLE_GIT" -o "$SYS_SCRIPT_PATH/$EISVOGEL_EXAMPLE_NAME"
    echo "Downloading $LETTER_EXAMPLE_NAME"
    curl -L "$LETTER_EXAMPLE_GIT" -o "$SYS_SCRIPT_PATH/$LETTER_EXAMPLE_NAME"
    echo "Downloading $INVOICE_EXAMPLE_NAME"
    curl -L "$INVOICE_EXAMPLE_GIT" -o "$SYS_SCRIPT_PATH/$INVOICE_EXAMPLE_NAME"
}

# ###
# Befehlszeilenargumente analysieren
# ###
if [ "$1" == "--install" ] || [ "$1" == "-i" ]; then
    # Überprüfen, ob die erforderlichen Pakete installiert sind
    if is_pip_installed && ! is_pip_package_installed "pandoc-latex-environment"; then
        # Paket installieren
        echo "Installing pandoc-latex-environment..."
        pip3 install pandoc-latex-environment
    fi

    # Überprüfen, ob Verzeichnisse vorhanden sind
    create_directory "$SYS_TEMPLATE_PATH"
    create_directory "$SYS_SCRIPT_PATH"

    # Vorlagen installieren
    install_update_templates

    # Skript in .local kopieren
    copy_script_to_local

    # Bash-Alias erstellen
    create_bash_alias

elif [ "$1" == "--new" ] || [ "$1" == "-n" ]; then
    echo "Creating new project structure"
    mkdir assets

    if [ -n "$2" ]; then
        case "$2" in
            "letter")
                echo "Creating letter.md template"
                cp "$SYS_SCRIPT_PATH/$LETTER_EXAMPLE_NAME" .
                ;;
            "invoice")
                echo "Creating invoice.md template"
                cp "$SYS_SCRIPT_PATH/$INVOICE_EXAMPLE_NAME" .
                ;;
            "eisvogel")
                echo "Creating report.md template"
                cp "$SYS_SCRIPT_PATH/$EISVOGEL_EXAMPLE_NAME" .
                ;;
            *)
                echo "Creating default.md template"
                cp "$SYS_SCRIPT_PATH/$DEFAULT_EXAMPLE_NAME" .
                ;;
        esac
    else
        echo "Creating default.md template"
        cp "$SYS_SCRIPT_PATH/$DEFAULT_EXAMPLE_NAME" .
    fi

elif [ "$1" == "--update" ] || [ "$1" == "-u" ]; then
    install_update_templates

elif [ "$1" == "--watch" ] || [ "$1" == "-w" ]; then
    is_inotify_installed
    # Alte Lock-Datei löschen
    rm -f "$LOCK_FILE"

    # Watcher für gespeicherte *.md-Dateien
    inotifywait --monitor --format "%f" --event modify ./ | while read -r changed; do
        if [[ "${changed##*.}" == "md" ]]; then
            if [ -e "$LOCK_FILE" ] && kill -0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
                echo "Script is currently running"
            else
                # Lock-Datei erstellen
                echo $$ >"$LOCK_FILE"

                # Pandoc-Befehl ausführen
                filename=$(basename -- "$changed")

                if [ -n "$2" ] && [ -f "$2" ]; then
                    filename=$(basename -- "$2")
                elif [ -n "$2" ]; then
                    echo "File: $2 not found"
                    rm "$LOCK_FILE"
                    exit 1
                fi

                filename="${filename%.*}"
                template_type=$(get_template_type "$filename.md")
                echo "Building document as $filename.pdf"

                if [ "$template_type" = "letter" ]; then
                    pandoc "$filename.md" -o "$filename.pdf" --template="$template_type"
                elif [ "$template_type" = "eisvogel" ]; then
                    echo "..."
                else
                    pandoc "$filename.md" -o "$filename.pdf" --template="$template_type" --filter pandoc-latex-environment --resource-path=./assets/ --listings
                fi

                sleep 4

                # Lock-Datei löschen
                rm "$LOCK_FILE"
            fi
        fi
    done

elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo ""
    echo "Usage:"
    printf "${FORMAT}" "sdoc -i, --install" "install project requirements"
    printf "${FORMAT}" "sdoc -n, --new" "create default project"
    printf "${FORMAT}" "sdoc -n, --new <type>" "type is default, letter, invoice, or eisvogel"
    printf "${FORMAT}" "sdoc -u, --update" "update templates"
    printf "${FORMAT}" "sdoc -w, --watch" "Watch for changes and build"
    printf "${FORMAT}" "sdoc -w, --watch <file>" "Watch for changes and build <file>"
    printf "${FORMAT}" "sdoc -nw" "combination of --new and --watch"
    printf "${FORMAT}" "sdoc -nw <file>" "combination of --new and --watch <file>"

else
    echo "$1: invalid option"
    echo "Try '--help' or '-h' for more information."
    exit 1
fi
