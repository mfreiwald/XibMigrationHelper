# XibMigrationHelper
Help to identifiy NamedColor usages in Xib &amp; Storyboard files

## Install

You can install the newest version with [mint](https://github.com/yonaskolb/Mint)

mint install mfreiwald/XibMigrationHelper

## Usage

> `xib-migration-helper [<folder-path>] [--emptyNamedColorsOnly]`

Show help prompt
> `mint run mfreiwald/XibMigrationHelper --help`

Analyze project at specific path
> `mint run mfreiwald/XibMigrationHelper "projectRoot"` 

Show all files with references to NamedColors but without using them in any view
> `mint run mfreiwald/XibMigrationHelper "projectRoot" --emptyNamedColorsOnly`
