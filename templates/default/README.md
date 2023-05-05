## Usage
To convert the markdown file to a PDF run:

```shell
pandoc ab.md -o ab.pdf --template="politik" --filter pandoc-latex-environment --resource-path=./assets/
```