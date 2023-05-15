
# SDOC
Das Skript bietet eine automatisierte Möglichkeit, Markdown-Dokumente mit verschiedenen LaTeX-Vorlagen zu konvertieren und basierend auf Änderungen automatisch zu aktualisieren. Es kann als Grundlage für die Erstellung und Verwaltung von Dokumentprojekten diene.

> Verwendete fremde Vorlagen: [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template), [Pandoc Letter Template Din5008](https://github.com/benedictdudel/pandoc-letter-din5008)

# Installation
* Herunterladen der ```sdoc.sh``` Datei
```sh
    wget https://raw.githubusercontent.com/gasts/pandoc-markdown/main/sdoc.sh
```
* Ausführbar machen des Skripts
```sh
    chmod +x sdoc.sh
```
* Installation
```sh
./sdoc.sh --install
```

**Abhängigkeiten:** Das Paket ```inotify-tools``` muss installiert sein.

# Verwendung
* Projekt dummy erstellen
```sh
sdoc --new
sdoc --watch
```
Bei jedem speichern von ```document.md``` wird das Skript automatisch ausgeführt und das PDF wird erzeugt.

# To-do
* Bessere Support für Quelltexthervorhebung im Default-Mode
* Das Eisvogel Template integrieren