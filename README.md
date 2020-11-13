.zsh
==========

Personal zsh configuration, somewhat sourced from Eevee at [veekun](http://veekun.com).

All the config scripts are written in perl because every system has perl and cpan package management system is rock solid; I haven't had it fail yet, even when automatically installing to weird places like os x and cygwin.

### Setup
zsh requires the .zshrc to be available, so create a ~/.zshrc with the lines:
```
source /path/to/this/repo/.zshrc
```
You can also just symlink ~/.zshrc to this .zshrc, although this sometimes screws with paths, even though I've taken pains to fix that; if it doesn't work, just use the first option.
