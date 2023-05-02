## Usage
To convert the markdown file to a PDF run:

```shell
pandoc letter.md -o letter.pdf --template="politik" --filter pandoc-latex-environment
```