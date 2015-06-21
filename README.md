.zsh
==========

Personal zsh configuration, somewhat sourced from Eevee at [veekun](http://veekun.com).

There is a file that is gitignored: `.zshbashpaths`. This is meant to add personal configuration options for your specific machine. I mostly use it to add folders with random code (for example, right now I've downloaded the firefox and emacs source) to my PATH.

All the config scripts are written in perl because every system has perl and cpan package management system is rock solid; I haven't had it fail yet, even when automatically installing to weird places like os x and cygwin.

### Setup
zsh requires the .zshrc to be available, so create a ~/.zshrc with the lines:
```
source /path/to/this/repo/.zshrc
```
You can also just symlink ~/.zshrc to this .zshrc, although this sometimes screws with paths, even though I've taken pains to fix that; if it doesn't work, just use the first option.
