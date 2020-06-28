# Horo (a.k.a KenOokamiHoro) 's .zshrc file
# Referenced from these awesome users and developers :-)
#   Lilydjwg:dotzsh https://github.com/lilydjwg/dotzsh
#   grml-zsh-config https://grml.org/zsh/#grmlzshconfig

# 基本设置 {{{1
_zdir=${ZDOTDIR:-$HOME}
HISTFILE=${_zdir}/.histfile
HISTSIZE=10000
SAVEHIST=10000
ZSH_PS_HOST=$(hostname)

zstyle :compinstall filename "$_zdir/.zshrc"
fpath=($_zdir/.zsh/completion $_zdir/.zsh/functions $_zdir/.zsh/config.d $fpath)
autoload -Uz compinit
compinit

# 确定环境 {{{1
OS=${$(uname)%_*}
if [[ $OS == "CYGWIN" || $OS == "MSYS" ]]; then
  OS=Linux
elif [[ $OS == "Darwin" ]]; then
  OS=FreeBSD
fi
# check first, or the script will end wherever it fails
zmodload zsh/regex 2>/dev/null && _has_re=1 || _has_re=0
unsetopt nomatch
zmodload zsh/subreap 2>/dev/null && subreap

for file in  $_zdir/.zsh/config.d/* ; do 
    source  "$file"
done

# 选项设置 -> $_zdir/.zsh/config.d/00-options
# 补全与 zstyle -> $_zdir/.zsh/config.d/01-zstyle
# 命令行编辑 -> $_zdir/.zsh/config.d/02-keybinding
# 别名 -> $_zdir/.zsh/config.d/03-alias
# Functions
# Place them in $_zdir/.zsh/functions
autoload zargs
autoload zmv

# load functions from  $_zdir/.zsh/functions/
for file in  $_zdir/.zsh/functions/* ; do 
    source  "$file"
done

# Environments {{{1
# re-tie fails for zsh 4
export -TU PYTHONPATH pythonpath 2>/dev/null
export -U PATH
# don't export FPATH
typeset -U FPATH
[[ -z $MAKEFLAGS ]] && (( $+commands[nproc] )) && {
  local n=$(nproc)
  export MAKEFLAGS="-j$n -l$n"
}
[[ -z $EDITOR ]] && (( $+commands[vim] )) && export EDITOR=vim

[[ -f $_zdir/.zsh/zshrc.local ]] && source $_zdir/.zsh/zshrc.local

# zsh {{{2
# 提示符
# %n --- 用户名
# %~ --- 当前目录
# %h --- 历史记录号
# git 分支显示 {{{3

if (( $+commands[git] )); then
  _nogit_dir=()
  for p in $nogit_dir; do
    [[ -d $p ]] && _nogit_dir+=$(realpath $p)
  done
  unset p

  _setup_current_branch_async () { # {{{4
    typeset -g _current_branch= vcs_info_fd=
    zmodload zsh/zselect 2>/dev/null

    _vcs_update_info () {
      eval $(read -rE -u$1)
      zle -F $1 && vcs_info_fd=
      exec {1}>&-
      # update prompt only when necessary to avoid double first line
      [[ -n $_current_branch ]] && zle reset-prompt
    }

    _set_current_branch () {
      _current_branch=
      [[ -n $vcs_info_fd ]] && zle -F $vcs_info_fd
      cwd=$(pwd -P)
      for p in $_nogit_dir; do
        if [[ $cwd == $p* ]]; then
          return
        fi
      done

      setopt localoptions no_monitor
      coproc {
        _br=$(git branch --no-color 2>/dev/null)
        if [[ $? -eq 0 ]]; then
          _current_branch=$(echo $_br|awk '$1 == "*" {print "%{\x1b[33m%}(git)-[" substr($0, 3) "]"}')
        fi
        # always gives something for reading, or _vcs_update_info won't be
        # called, fd not closed
        #
        # "typeset -p" won't add "-g", so reprinting prompt (e.g. after status
        # of a bg job is printed) would miss it
        #
        # need to substitute single ' with double ''
        print "typeset -g _current_branch='${_current_branch//''''/''}'"
      }
      disown %{\ _br 2>/dev/null
      exec {vcs_info_fd}<&p
      # wait 0.1 seconds before showing up to avoid unnecessary double update
      # precmd functions are called *after* prompt is expanded, and we can't call
      # zle reset-prompt outside zle, so turn to zselect
      zselect -r -t 10 $vcs_info_fd 2>/dev/null
      zle -F $vcs_info_fd _vcs_update_info
    }
  }

  _setup_current_branch_sync () { # {{{4
    _set_current_branch () {
      _current_branch=
      cwd=$(pwd -P)
      for p in $_nogit_dir; do
        if [[ $cwd == $p* ]]; then
          return
        fi
      done

      _br=$(git branch --no-color 2>/dev/null)
      if [[ $? -eq 0 ]]; then
        _current_branch=$(echo $_br|awk '{if($1 == "*"){print "%{\x1b[33m%}(git)-[" substr($0, 3) "]"}}')
      fi
    }
  } # }}}

  if [[ $_has_re -ne 1 ||
    $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-5]' ]]; then
    # zsh 5.0.5 has a CPU 100% bug with zle -F
    _setup_current_branch_sync
  else
    _setup_current_branch_async
  fi
  typeset -gaU precmd_functions
  precmd_functions+=_set_current_branch
fi
# }}}3
[[ -n $ZSH_PS_HOST && $ZSH_PS_HOST != \(*\)\  ]] && ZSH_PS_HOST="($ZSH_PS_HOST) "
setopt PROMPT_SUBST
E=$'\x1b'
# reset on the second line to make it the same in tmux + ncurses 6.0
PS1="${E} %B%F{red}%(?..%? )%f%b%B%F{blue}%n%f%b@%M %B%60<..<%~%<< %b\$_current_branch 
%{${E}[0m%}%(!.%{${E}[0;31m%}#.%{${E}[1;34m%}$)%{${E}[0m%} "
# 次提示符：使用暗色
PS2="%{${E}[2m%}%_>%{${E}[0m%} "
# 右边的提示
RPS1="%(1j.%{${E}[1;33m%}%j .)%{${E}[m%}%*"
unset E

CORRECT_IGNORE='_*'
READNULLCMD=less
watch=(notme root)
WATCHFMT='%n has %a %l from %M'
REPORTTIME=5

# TeX{{{2
export TEXMFCACHE=${XDG_CACHE_HOME:-$HOME/.cache}
export OSFONTDIR=$HOME/.fonts:/usr/share/fonts/TTF

# gstreamer mp3 标签中文设置{{{2
export GST_ID3_TAG_ENCODING=GB18030:UTF-8
export GST_ID3V2_TAG_ENCODING=GB18030:UTF-8

# 图形终端下(包括ssh登录时)的设置{{{2
if [[ -n $DISPLAY && -z $SSH_CONNECTION ]]; then
  export BROWSER=firefox
  export wiki_browser=firefox
  export AGV_EDITOR='vv ''$file:$line:$col'''
else
  export AGV_EDITOR='vim +"call setpos(\".\", [0, $line, $col, 0])" ''$file'''
fi
if [[ -n $DISPLAY || -n $SSH_CONNECTION ]]; then
  # 让 less 将粗体/下划线等显示为彩色
  export LESS_TERMCAP_mb=$'\x1b[01;31m'
  export LESS_TERMCAP_md=$'\x1b[01;38;5;74m'
  export LESS_TERMCAP_me=$'\x1b[0m'
  export LESS_TERMCAP_se=$'\x1b[0m'
  export LESS_TERMCAP_so=$'\x1b[7m'
  export LESS_TERMCAP_ue=$'\x1b[0m'
  export LESS_TERMCAP_us=$'\x1b[04;38;5;146m'

  if [[ $TERM == linux ]]; then
    _256colors=0
  else
    [[ $TERM != *color* ]] && export TERM=${TERM%%[.-]*}-256color
    _256colors=1
  fi
else
  # tty 下光标显示为块状
  echo -ne "\e[?6c"
  zshexit () {
    [[ $SHLVL -eq 1 ]] && echo -ne "\e[?0c"
  }
  [[ $TERM == *color* ]] && _256colors=1
  # Set locale to English on getty
  LANG=en_US.UTF-8
  LC_CTYPE="en_US.UTF-8"
  LC_NUMERIC="en_US.UTF-8"
  LC_TIME="en_US.UTF-8"
  LC_COLLATE="en_US.UTF-8"
  LC_MONETARY="en_US.UTF-8"
  LC_MESSAGES="en_US.UTF-8"
  LC_PAPER="en_US.UTF-8"
  LC_NAME="en_US.UTF-8"
  LC_ADDRESS="en_US.UTF-8"
  LC_TELEPHONE="en_US.UTF-8"
  LC_MEASUREMENT="en_US.UTF-8"
  LC_IDENTIFICATION="en_US.UTF-8"
  LC_ALL=
fi
if [[ $OS = Linux ]]; then
  # under fbterm
  # can't see parent on some restricted systems
  if [[ $_has_re -eq 1 &&
    $(</proc/$PPID/cmdline) =~ '(^|/)fbterm' ]] 2>/dev/null; then
    export TERM=fbterm
    export LANG=en_US.UTF-8
    # This term is quirk. ls doesn't like it.
    # _256colors=1
  fi
  if [[ $_256colors -eq 1 ]]; then
    export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.JPG=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.webm=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.m4a=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.opus=38;5;45:*.vorbis=38;5;45:*.3gp=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:*~=38;5;244:'
  else
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
  fi
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
unset _256colors
unset _has_re

# 其它程序 {{{2
AUTOJUMP_KEEP_SYMLINKS=1
export LESS="-FRXM"
# default has -S
export SYSTEMD_LESS="${LESS#-}K"
# git-subrepo completer needs this:
GIT_SUBREPO_ROOT=/

# 其它 {{{1

# When starting as a non-login shell
[[ -z $functions[j] && -f /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
# Debian Wheezy
[[ -z $functions[j] && -f /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh
# FreeBSD
[[ -z $functions[j] && -f /usr/local/share/autojump/autojump.zsh ]] && source /usr/local/share/autojump/autojump.zsh
[[ -z $functions[j] && -f ${_zdir}/.zsh/autojump.zsh ]] && source ${_zdir}/.zsh/autojump.zsh
# if autojump loads but the directory is readonly, remove the chpwd hook
if [[ ${chpwd_functions[(i)autojump_chpwd]} -le ${#chpwd_functions} && \
  -d ~/.local/share/autojump && ! -w ~/.local/share/autojump ]]; then
  chpwd_functions[(i)autojump_chpwd]=()
fi

_plugin=${_zdir}/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
  FAST_HIGHLIGHT[use_async]=1
fi
_plugin=${_zdir}/.zsh/plugins/sk-tools.zsh
if [[ -f $_plugin ]]; then
  . $_plugin
fi
unset _plugin


# precmd() will run before commands.
precmd() {
  # Changing Terminal Title
  echo -n -e "\033]0;$(whoami)@$(hostname):$(pwd)\007"
}

unset OS
setopt nomatch
return 0

# vim:fdm=marker

