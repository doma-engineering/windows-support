# WSL console is broken

Some users report issues with `<Tab>` handling, some report issues with Unicode, some report both, some report none.

Either way, it does seem like WSL console as well as running `wsl.exe` aren't sustainable options.

# Quick and dirty method to get a working WSL console

 - Install VSCode, which has its own terminal emulator
 - Click F1 and choose "Remote-WSL: New window"
 - Press `` C-` ``
 - You have a reasonable, standard-adhering, very slow, terminal emulator

# Time-tested an powerful, but awkward and intrusive method

 - Install [Cygwin](https://cygwin.com/install.html)
    - Choose Internet installation
    - Choose a mirror close to you that you can reasonably trust
    - Install at least the packages listed in `Comfortable Cygwin.md` file in this repository
 - While it installs, make a `C:\Scripts` directory in Windows
 - Put `pfwsl.ps1` script you can find in this repository into `C:\Scripts`
 - Enable it in Task Scheduler as shown here: https://youtu.be/IrvXPw2WGIc
 - Run the task. Now you should be able to `ssh` to localhost.
 - After `cygwin` is installed, run `mintty`, also known as `Cygwin64 Terminal`
 - Add `ssh localhost` to your `.bashrc`. Now every time you're opening a new shell, you'll get dropped into WSL. If you need to do something in Cygwin, just `C-d` from that `ssh` shell. (I think it may mess with outgoing rsync, but I don't think it should be a big problem). If it is, remove this line and write `ssh localhost` every time you need to do into WSL.

That's it, now you have a reasonable old-school MinTTY terminal, but also, SSH enabled in your WSL, which is sometimes helpful.

> Hint! It isn't as helpful as you may think because. You can access WSL files via `\\wsl$` and Windows files via `/mnt/c`. This directory sharing enabled by default also has security implications... You probably shouldn't dissect malware in WSL thinking it's an isolated VM.

# Less deranged alternatives (I didn't try)

## Using Cmder or other ConEmu frontends

I've tried it, but it didn't work for some reason. I don't remember much, but if someone has a modern and working solution which doesn't involve cygwin, please share.

## Using Alacrity on Windows

I haven't tried it, but it seems like Alacrity is cross-platform enough to be usable on Windows.


# Good `bash` experience

I want to say straight away that `bash` historically was less feature-rich than, say, `zsh`, but these days tools like [`fzf`](https://www.youtube.com/watch?v=tB-AgxzBmH8) turn `bash` into a very nice system. I don't use fzf yet, but I'd love to integrate it into my `bash`.

If you have the access, you can download and personalise [my minimalist bashrc](https://github.com/doma-engineering/infrastructure/blob/wsl/conflagrate/home/sweater/.bashrc).
If you don't, here are some key outtakes that you should incorporate into your shell.

## Do **nothing** in non-interactive mode

```
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
```

> Hint! This may be the most important thing I have listed.

## PS1 prompt

```
ps1_date="\[$(tput bold)\]\[$(tput setaf 8)\]\$(date +'%a %b %d %H:%M:%S:%N')"
ps1_user="\[$(tput setaf 80)\]\u\[$(tput setaf 226)\]@\[$(tput setaf 80)\]\h"
ps1_path="\[$(tput setaf 8)\]\w"
ps1_lambda="\[$(tput setaf 8)\]λ\[$(tput sgr0)\]"

git_prompt() {
  local ref="$(git symbolic-ref -q HEAD 2>/dev/null)"
  if [ -n "$ref" ]; then
    echo "$(tput setaf 241)(${ref#refs/heads/}) "
  fi
}

export PS1="${ps1_date} ${ps1_user} ${ps1_path} \$(git_prompt)\n${ps1_lambda} "
```

## VI mode, VIM as default editor, screen-256color terminfo

```
set -o vi

export EDITOR="vim"
export TERM="screen-256color"
```

## Saner history

```
HISTCONTROL=ignoredups:erasedups
HISTIGNORE=' *'
HISTSIZE=''
shopt -s histappend
```

## Manually change title

```
function mk_bash_title() {
  echo -ne "\e]0;${1}\a"
}
export mk_bash_title

function set_bash_title() {
  PROMPT_COMMAND="mk_bash_title \"$1\""
}
export set_bash_title
```

> Hint! You should bre able to use `history 1 | sed "s/^[ ]*[0-9]*[ ]*//g"` in `trap` to set the terminal name to whatever was the latest command ran. Warning! This *will* mess up your terminals if the trap will happen in non-interactive mode, for example, while running `rsync`. Make sure to never trap and echo in non-interactive modes!

## Aliases

```
alias rg='rg --color=always'
alias less='less -R'
alias emacs='emacs -nw'
alias vi='emacsclient -c -nw'
alias ls='ls -p'
```

## Direnv and nix

> Warning! Don't copy-paste this if you don't know what is it about.

When you run [bootstrap_home_manager.sh script](https://github.com/cognivore/nix-home/blob/main/boostrap_home_manager.sh), it asks you to change `~/.config/nixpkgs/home.nix` and add this stuff to your .bashrc:

```
# Nix
if [ -e /home/sweater/.nix-profile/etc/profile.d/nix.sh ]; then . /home/sweater/.nix-profile/etc/profile.d/nix.sh; fi

# Direnv
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
source $HOME/.nix-profile/share/nix-direnv/direnvrc
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
eval "$(direnv hook bash)"

# boostrap_home_manager.sh: https://raw.githubusercontent.com/cognivore/nix-home/main/boostrap_home_manager.sh
export PATH=$HOME/.local/nbin:$PATH
```

# Good `vim` experience

Again, if you have access, [fetch my vimrc](https://github.com/doma-engineering/infrastructure/blob/wsl/conflagrate/home/sweater/.vimrc) and [.vim directory](https://github.com/doma-engineering/infrastructure/tree/wsl/conflagrate/home/sweater/.vim) modify them to your needs.

Otherwise, install [`ctrlp`](https://github.com/ctrlpvim/ctrlp.vim#install), which would allow you to open files deep inside the current directory fuzzily by pressing `C-p` and typing what little you remember about the file name.

> Hint! while in _Ctrlp_ mode, `C-y` will create a file and open it in a new split.

My Ctrlp is installed in a as an unmanaged plugin, thus I need to have `set runtimepath^=~/.vim/bundle/ctrlp.vim` in my .vimrc!

## Disable dangerous keys, add useful toggles for tabs and paste mode

```
""""""""""""""""""""""""""""""
let mapleader=","
set pastetoggle=<Leader>v
map <Leader>. :tabprevious<CR>
map <Leader>/ :tabnext<CR>
map Q <nop>
map K <nop>
nnoremap <PageUp> <nop>
noremap <PageDown> <nop>
""""""""""""""""""""""""""""""
```

This allows you to:
 - toggle paste mode by pressing `,v`
 - go to the next / previous tabs with`,/` / `,.`


## Delete trailing spaces on save (sorry Markdown power-users)

```
""""""""""""""""""""""""""""""
autocmd BufWritePre * %s/\s\+$//e
""""""""""""""""""""""""""""""
autocmd BufRead,BufEnter *.txt,*.md,*.markdown setlocal textwidth=72
""""""""""""""""""""""""""""""
```

## Sensible, yet dangerous defaults

> Warning! This disables swap files and backups! It's a pretty idiotic thing to do, but that's how I roll, because I feel it saves me more time than answering a question every time I killed `VIM`.

```
""""""""""""""""""""""""""""""
set cm=blowfish2
set nocompatible
set noswapfile
set nobackup
set number
set relativenumber
set smartindent
set tabstop=2
set shiftwidth=2
set backspace=2
set expandtab
set nohlsearch
""""""""""""""""""""""""""""""
```

## Monochrome VIM with 256 colours

```
""""""""""""""""""""""""""""""
syntax off
filetype on
set background=dark
set t_Co=256
""""""""""""""""""""""""""""""
```

# Sensible tmux configuration (`C-a` FTW!)

 * This configuration uses `C-a` instead of the default `C-b` as the lead hotkey.
 * It uses more reasonable `C-a |` for vertical split and `C-a -` for horizontal split.
 * VIM movement keys `hjkl` are accepted for movements across splits.
 * This configuration supports 256 colour terminals and Emacs's "evil mode".

```
#### USABILITY (VIM/Screen-like)
set -g prefix C-a
bind-key C-a last-window
set-option -g history-limit 100000
setw -g xterm-keys on
set-option -g default-terminal "screen-256color"
setw -g mode-keys vi
set-option -g allow-rename off
set-option -g automatic-rename off

# NB! Emacs evil-mode fix
set -s escape-time 0

#### Splitting and walking around splits
bind-key | split-window -h
bind-key - split-window

unbind-key j
bind-key j select-pane -D

unbind-key k
bind-key k select-pane -U

unbind-key h
bind-key h select-pane -L

unbind-key l
bind-key l select-pane -R

#### 256 Co
set -g terminal-overrides 'xterm:colors=256'
```
