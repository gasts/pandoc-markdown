## Usage
To convert the markdown file to a PDF run:

```shell
pandoc letter.md -o letter.pdf --template="letter"
```

## Customization
There are two ways to customize the letter. You can use the exported KOMA-variables via yaml or use a custom lco (letter class options) file which you can reference in your yaml metadata.

### 1. Letter Class Options (`.lco`)
Create a new file `defaults.lco` with the following content:

```shell
\ProvidesFile{defaults.lco}

\setkomavar{opening}{Dear Sir or Madam,}
\setkomavar{closing}{Sincerely,}
```

Reference the `defaults.lco` file within you yaml metadata:

```yaml
---
letteroption:
  - defaults
---
```

## 2. Variables
The template supports all variables from the official LaTeX template plus additional variables from scrlttr2. Those variables are:
|name                |description                                            |
|--------------------|-------------------------------------------------------|
|addresseeimage|commands used to print the postpaid postmark for the addrfield backgroundimage option or the postpaid address for the addrfield=image option|
|backaddress|return address for window envelopes|
|backaddressseparator|separator within the return address|
|closing|concluding text|
|ccseparator|separator between title of additional addresses (cc list) and additional addresses|
|cc|distribution list|
|customer|customer number|
|customername|name of customer number|
|date|date|
|datename|name of date|
|emailseparator|separator between email name and email address|
|enclseparator|separator between title of enclosure and enclosures|
|faxseparator|separator between title of fax and fax number|
|firstfooter|footer of the letterhead page|
|firsthead|header of the letterhead page|
|fromaddress|sender’s address without sender name|
|fromalign|where the sender information should be placed on the first page|
|frombank|sender’s bank details|
|fromemail|sender’s e-mail|
|fromfax|sender’s fax number|
|fromlogo|commands for inserting the sender’s logo|
|frommobilephone|sender’s mobile telephone number|
|fromname|complete name of sender|
|fromphone|sender’s telephone number|
|fromurl|URL of the sender, e. g. of the sender’s homepage|
|fromzipcode|ZIP code (postal code) of the sender for the postpaid postmark of the addrfield=PP option|
|invoice|invoice number|
|invoicename|name of invoice number|
|letteroption|to load lco files|
|location|extra details of the sender|
|myref|sender’s reference|
|nextfoot|footer using page style headings or myheadings|
|nexthead|header using page style headings or myheadings|
|opening|salutation|
|phoneseparator|separator between title of telephone and telephone number|
|place|sender’s location; used next to date|
|placeseparator|separator between location and date|
|PPdatamatrix|command to print the data array for the addrfield=PP option|
|PPcode|commands for the sender’s identification code for the addrfield=PP option|
|signature|signature annotation beneath the closing text of the letter|
|specialmail|delivery method|
|subject|letter’s subject|
|subjectseparator|separator between subject title and subject|
|title|letter title|
|toaddress|address of recipient without recipient name|
|toname|complete name of recipient|
|yourmail|date of recipient’s referenced mail|
|yourmailname|name of date of recipient’s referenced mail|
|yourref|recipient’s reference|
|yourrefname|name of the recipient’s reference|
|zipcodeseparator|separator between the title of ZIP code (postal code) and the code itself|


