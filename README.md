# XibMigrationHelper
Help to identifiy NamedColor usages in Xib &amp; Storyboard files

## Install

You can install the newest version with [mint](https://github.com/yonaskolb/Mint)

mint install mfreiwald/XibMigrationHelper

## Usage

> `xib-migration-helper [<folder-path>] [--file <file>] [--show-all] [--emptys]`

Show help prompt
> `mint run mfreiwald/XibMigrationHelper --help`

```bash
USAGE: xib-migration-helper [<folder-path>] [--file <file>] [--show-all] [--emptys]

ARGUMENTS:
  <folder-path>           Path to folder to analyze. (default: .)

OPTIONS:
  -f, --file <file>       Filter for specific files
  -a, --show-all          Show all files at once
  -e, --emptys            Show only files which have a NamedColor reference but didn't uses it.
  -h, --help              Show help information.
```

Analyze project at specific path
> `mint run mfreiwald/XibMigrationHelper "projectRoot"` 

Show all files with references to NamedColors but without using them in any view
> `mint run mfreiwald/XibMigrationHelper "projectRoot" --emptyNamedColorsOnly`

Show all analyzed files (otherwise you will go step by step)
> `mint run mfreiwald/XibMigrationHelper "projectRoot"` --show-all 

Analyze only a specific file (simple path.contains check)
> `mint run mfreiwald/XibMigrationHelper "projectRoot"` -f MyView.xib
