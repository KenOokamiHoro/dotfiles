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
fpath=($_zdir/.zsh/Completion $_zdir/.zsh/functions $fpath)
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

# 选项设置{{{1
unsetopt beep
# 自动记住已访问目录栈
setopt auto_pushd
# don't push the same dir twice.
setopt pushd_ignore_dups
setopt pushd_minus
# 允许在交互模式中使用注释
setopt interactive_comments
# disown 后自动继续进程
setopt auto_continue
setopt extended_glob
# 单引号中的 '' 表示一个 ' （如同 Vimscript 中者）
setopt rc_quotes
# 补全列表不同列可以使用不同的列宽
setopt listpacked
# 补全 identifier=path 形式的参数
setopt magic_equal_subst
# 为方便复制，右边的提示符只在最新的提示符上显示
setopt transient_rprompt
# setopt 的输出显示选项的开关状态
setopt ksh_option_print
setopt no_bg_nice
setopt noflowcontrol
stty -ixon # 上一行在 tmux 中不起作用

# 历史记录{{{2
# 不保存重复的历史记录项
setopt hist_save_no_dups
setopt hist_ignore_dups
# 在命令前添加空格，不将此命令添加到记录文件中
setopt hist_ignore_space
# append history list to the history file; this is the default but we make sure
# because it's required for share_history.
setopt append_history
# import new commands from the history file also in other zsh-session
setopt share_history
# save each command's beginning timestamp and the duration to the history file
setopt extended_history
# If a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
setopt histignorealldups
# in order to use #, ~ and ^ for filename generation grep word
# *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word not in compressed files
# don't forget to quote '^', '~' and '#'!
setopt extended_glob
# display PID when suspending processes as well
setopt longlistjobs
# report the status of backgrounds jobs immediately
setopt notify
# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt hash_list_all
# not just at the end
setopt completeinword
# Don't send SIGHUP to background processes when the shell exits.
setopt nohup
# avoid "beep"ing
setopt nobeep
# * shouldn't match dotfiles. ever.
setopt noglobdots
# use zsh style word splitting
setopt noshwordsplit
# don't error out when unset parameters are used
setopt unset
# zsh 4.3.6 doesn't have this option
setopt hist_fcntl_lock 2>/dev/null
if [[ $_has_re -eq 1 && 
  ! ( $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-4]' ) ]]; then
  setopt hist_reduce_blanks
else
  # This may cause the command messed up due to a memcpy bug
fi

# 补全与 zstyle {{{1
# 自动补全 {{{2
# 用本用户的所有进程补全
zstyle ':completion:*:processes' command 'ps -afu$USER'
zstyle ':completion:*:*:*:*:processes' force-list always
# 进程名补全
zstyle ':completion:*:processes-names' command  'ps c -u ${USER} -o command | uniq'
# 警告显示为红色
zstyle ':completion:*:warnings' format $'\e[01;31m -- No Matches Found --\e[0m'
# 描述显示为淡色
zstyle ':completion:*:descriptions' format $'\e[2m -- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[01;33m -- %d (errors: %e) --\e[0m'
# cd 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
# 在 .. 后不要回到当前目录
zstyle ':completion:*:cd:*' ignore-parents parent pwd
# complete manual by their section, from grml
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*' menu select
# 分组显示
zstyle ':completion:*' group-name ''
# 在最后尝试使用文件名
if [[ $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-5]' ]]; then
  zstyle ':completion:*' completer _complete _match _approximate _expand_alias _ignored _files
else
  zstyle ':completion:*' completer _complete _extensions _match _approximate _expand_alias _ignored _files
fi
# 修正大小写
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle -e ':completion:*' special-dirs \
  '[[ $PREFIX == (../)#(|.|..) ]] && reply=(..)'
# 使用缓存。某些命令的补全很耗时的（如 aptitude）
zstyle ':completion:*' use-cache on
_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
zstyle ':completion:*' cache-path $_cache_dir
unset _cache_dir
# complete user-commands for git-*
# https://pbrisbin.com/posts/deleting_git_tags_with_style/
zstyle ':completion:*:*:git:*' user-commands ${${(M)${(k)commands}:#git-*}/git-/}

# Auto complete from lilydjwg {{{2
zstyle ':completion:*:*:pdf2png:*' file-patterns \
  '*.pdf:pdf-files:pdf\ files *(-/):directories:directories'
zstyle ':completion:*:*:x:*' file-patterns \
  '*.{7z,bz2,gz,rar,tar,tbz,tgz,zip,chm,xz,exe,xpi,apk,maff,crx}:compressed-files:compressed\ files *(-/):directories:directories'
zstyle ':completion:*:*:evince:*' file-patterns \
  '*.{pdf,ps,eps,dvi,djvu,pdf.gz,ps.gz,dvi.gz}:documents:documents *(-/):directories:directories'
zstyle ':completion:*:*:gbkunzip:*' file-patterns '*.zip:zip-files:zip\ files *(-/):directories:directories'
zstyle ':completion:*:*:feh:*' file-patterns '*.{png,gif,jpg,svg}:images:images *(-/):directories:directories'
zstyle ':completion:*:*:sxiv:*' file-patterns '*.{png,gif,jpg}:images:images *(-/):directories:directories'
zstyle ':completion:*:*:timidity:*' file-patterns '*.mid'

# Auto complete from grml-zsh-conig {{{2
# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'       original true

# activate color-completion
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

# format on completion
zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*'        tag-order all-expansions
zstyle ':completion:*:history-words'   list false

# activate menu
zstyle ':completion:*:history-words'   menu yes

# ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes

# match uppercase from lowercase
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

# separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''

if [[ "$NOMENU" -eq 0 ]] ; then
  # if there are more than 5 options allow selecting from a menu
  zstyle ':completion:*'               menu select=5
else
  # don't use any menus at all
  setopt no_auto_menu
fi

zstyle ':completion:*:messages'        format '%d'
zstyle ':completion:*:options'         auto-description '%d'

# describe options in full
zstyle ':completion:*:options'         description 'yes'

# on processes completion complete all user processes
zstyle ':completion:*:processes'       command 'ps -au$USER'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# provide verbose completion information
zstyle ':completion:*'                 verbose true

# recent (as of Dec 2007) zsh versions are able to provide descriptions
# for commands (read: 1st word in the line) that it will list for the user
# to choose from. The following disables that, because it's not exactly fast.
zstyle ':completion:*:-command-:*:'    verbose false

# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'          prompt 'correct to: %e'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                          /usr/local/bin  \
                                          /usr/sbin       \
                                          /usr/bin        \
                                          /sbin           \
                                          /bin            \

# provide .. as a completion
zstyle ':completion:*' special-dirs ..

# run rehash on completion so new installed program are found automatically:
function _force_rehash () {
  (( CURRENT == 1 )) && rehash
  return 1
}

## correction
# some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
if [[ "$NOCOR" -gt 0 ]] ; then
  zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored
  setopt nocorrect
else
  # try to be smart about when to use what completer...
  setopt correct
  zstyle -e ':completion:*' completer '
      if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
          _last_try="$HISTNO$BUFFER$CURSOR"
          reply=(_complete _match _ignored _prefix _files)
      else
          if [[ $words[1] == (rm|mv) ]] ; then
              reply=(_complete _files)
          else
              reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
          fi
      fi'
fi

# command for process lists, the local web server details and host completion
zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

# Some functions, like _apt and _dpkg, are very slow. We can use a cache in
# order to speed things up
if [[ ${GRML_COMP_CACHING:-yes} == yes ]]; then
  GRML_COMP_CACHE_DIR=${GRML_COMP_CACHE_DIR:-${ZDOTDIR:-$HOME}/.cache}
  if [[ ! -d ${GRML_COMP_CACHE_DIR} ]]; then
      command mkdir -p "${GRML_COMP_CACHE_DIR}"
  fi
  zstyle ':completion:*' use-cache  yes
  zstyle ':completion:*:complete:*' cache-path "${GRML_COMP_CACHE_DIR}"
fi

# host completion {{2
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
  $(hostname)
  "$_ssh_config_hosts[@]"
  "$_ssh_hosts[@]"
  "$_etc_hosts[@]"
  localhost
)
zstyle ':completion:*:hosts' hosts $hosts

# use generic completion system for programs not yet defined; (_gnu_generic works
# with commands that provide a --help option with "standard" gnu-like output.)
for compcom in cp deborphan df feh fetchipac gpasswd head hnb ipacsum mv \
              pal stow uname ; do
  [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
done; unset compcom

# see upgrade function in this file
compdef _hosts upgrade
# .zfs handling {{{2
if [[ -f /proc/self/mountinfo ]]; then
  _get_zfs_fake_files () {
    reply=($(awk -vOFS=: -vORS=' ' '$9 == "zfs" && $7 !~ /^master:/ { print $5, ".zfs" }' /proc/self/mountinfo))
  }
  zstyle -e ':completion:*' fake-files _get_zfs_fake_files
fi
# 接受路径中已经匹配的中间项，这将支持 .zfs 隐藏目录
# zstyle ':completion:*' accept-exact-dirs true

# 命令行编辑{{{1
bindkey -e

# ^Xe 用$EDITOR编辑命令
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

zle -C complete-file menu-expand-or-complete _generic
zstyle ':completion:complete-file:*' completer _files

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# zsh 5.1+ uses bracketed-paste-url-magic
if [[ $ZSH_VERSION =~ '^[0-4]\.' || $ZSH_VERSION =~ '^5\.0\.[0-9]' ]]; then
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
  toggle-uqm () {
    if zle -l self-insert; then
      zle -A .self-insert self-insert && zle -M "switched to self-insert"
    else
      zle -N self-insert url-quote-magic && zle -M "switched to url-quote-magic"
    fi
  }
  zle -N toggle-uqm
  bindkey '^X$' toggle-uqm
fi

# better than copy-prev-word
bindkey "^[^_" copy-prev-shell-word

insert-last-word-r () {
  zle insert-last-word -- 1
}
zle -N insert-last-word-r
bindkey "\e_" insert-last-word-r

autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey '\e=' copy-earlier-word

autoload -Uz prefix-proxy
zle -N prefix-proxy
bindkey "^Xp" prefix-proxy

zmodload zsh/complist
bindkey -M menuselect '^O' accept-and-infer-next-history

bindkey "^X^I" complete-file
bindkey "^X^f" complete-file
bindkey "^U" backward-kill-line
bindkey "^]" vi-find-next-char
bindkey "\e]" vi-find-prev-char
bindkey "\eq" push-line-or-edit
bindkey -s "\e[Z" "^P"
bindkey '^Xa' _expand_alias
bindkey '^[/' _history-complete-older
bindkey '\e ' set-mark-command
bindkey "\e[3~" delete-char

# 用单引号引起最后一个单词
# FIXME 如何引起光标处的单词？
bindkey -s "^['" "^[] ^f^@^e^[\""

bindkey '^[p' up-line-or-search
bindkey '^[n' down-line-or-search
bindkey "e[1~" beginning-of-line
bindkey "e[4~" end-of-line
bindkey "e[5~" beginning-of-history
bindkey "e[6~" end-of-history
bindkey "e[3~" delete-char
bindkey "e[2~" quoted-insert
bindkey "e[5C" forward-word
bindkey "eOc" emacs-forward-word
bindkey "e[5D" backward-word
bindkey "eOd" emacs-backward-word
bindkey "ee[C" forward-word
bindkey "ee[D" backward-word
bindkey "^H" backward-delete-word

# jump to a position in a command line {{{2
# https://github.com/scfrazer/zsh-jump-target
autoload -Uz jump-target
zle -N jump-target
bindkey "^J" jump-target

# restoring an aborted command-line {{{2
# unsupported with 4.3.17
if zle -la split-undo; then
  zle-line-init () {
    if [[ -n $ZLE_LINE_ABORTED ]]; then
      _last_aborted_line=$ZLE_LINE_ABORTED
    fi
    if [[ -n $_last_aborted_line ]]; then
      local savebuf="$BUFFER" savecur="$CURSOR"
      BUFFER="$_last_aborted_line"
      CURSOR="$#BUFFER"
      zle split-undo
      BUFFER="$savebuf" CURSOR="$savecur"
    fi
  }
  zle -N zle-line-init
  zle-line-finish() {
    unset _last_aborted_line
  }
  zle -N zle-line-finish
fi
# move by shell word {{{2
zsh-word-movement () {
  # see select-word-style for more
  local -a word_functions
  local f

  word_functions=(backward-kill-word backward-word
    capitalize-word down-case-word
    forward-word kill-word
    transpose-words up-case-word)

  if ! zle -l $word_functions[1]; then
    for f in $word_functions; do
      autoload -Uz $f-match
      zle -N zsh-$f $f-match
    done
  fi
  # set the style to shell
  zstyle ':zle:zsh-*' word-style shell
}
zsh-word-movement
unfunction zsh-word-movement
bindkey "\eB" zsh-backward-word
bindkey "\eF" zsh-forward-word
bindkey "\eW" zsh-backward-kill-word
# Esc-Esc 在当前/上一条命令前插入 sudo {{{2
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * && $UID -ne 0 ]] && {
      typeset -a bufs
      bufs=(${(z)BUFFER})
      while (( $+aliases[$bufs[1]] )); do
        local expanded=(${(z)aliases[$bufs[1]]})
        bufs[1,1]=($expanded)
        if [[ $bufs[1] == $expanded[1] ]]; then
          break
        fi
      done
      bufs=(sudo $bufs)
      BUFFER=$bufs
    }
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
# 插入当前的所有补全 http://www.zsh.org/mla/users/2000/msg00601.html {{{2
_insert_all_matches () {
    setopt localoptions nullglob rcexpandparam extendedglob noshglob
    unsetopt markdirs globsubst shwordsplit nounset ksharrays
    compstate[insert]=all
    compstate[old_list]=keep
    _complete
}
zle -C insert-all-matches complete-word _insert_all_matches
bindkey '^Xi' insert-all-matches

# Search history with text on the line, powered by Zle's history-search.
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward


# 别名 {{{1
# 命令别名 {{{2
alias ll='ls -lh'
alias la='ls -A'
if [[ $OS == 'Linux' ]]; then
  alias ls='ls --color=auto'
elif [[ $OS == 'FreeBSD' ]]; then
  alias ls='ls -G'
elif (( $+commands[colorls] )); then
  alias ls='colorls -G'
else
  alias ls='ls -F'
fi
if [[ $OS == 'Linux' || $OS == 'FreeBSD' ]]; then
  alias grep='grep --color=auto'
fi
alias n='thunar'
alias py='python3'
alias svim="vim -i NONE"
alias rv='EDITOR="vim --servername GVIM --remote-tab-wait"'
alias :q="exit"

# grc aliases 
if (( $+aliases[colourify] )); then
  # default is better
  unalias gcc g++ 2>/dev/null || true
  # bug: https://github.com/garabik/grc/issues/72
  unalias mtr     2>/dev/null || true
  # buffering issues: https://github.com/garabik/grc/issues/25
  unalias ping    2>/dev/null || true
fi

# for systemd 230+
# see https://github.com/tmux/tmux/issues/428
if [[ $_has_re -eq 1 ]] && \
  (( $+commands[tmux] )) && (( $+commands[systemctl] )); then
  [[ $(systemctl --version) =~ 'systemd ([0-9]+)' ]] || true
  if [[ $match -ge 230 ]]; then
    tmux () {
      if command tmux has; then
        command tmux $@
      else
        systemd-run --user --scope tmux $@
      fi
    }
  fi
  unset match
fi

alias nicest="nice -n19 ionice -c3"

# 查看进程数最多的程序
alias topnum="ps -e|sort -k4|awk '{print \$4}'|uniq -c|sort -n|tail"

alias nonet="HTTP_PROXY='http://localhost:1' HTTPS_PROXY='http://localhost:1' FTP_PROXY='http://localhost:1' http_proxy='http://localhost:1' https_proxy='http://localhost:1' ftp_proxy='http://localhost:1'"
alias fromgbk="iconv -t latin1 | iconv -f gb18030"
alias swaptop='watch -n 1 "swapview | tail -\$((\$LINES - 2)) | cut -b -\$COLUMNS"'
alias pkg-check='comm -23 <(pacman -Qetq|sort) <(awk ''{print $1}'' ~/etc/pkg-why|sort) | shuf | tail -$(( LINES - 4 ))'

# for systemd {{{3
alias sysuser="systemctl --user"
function juser () {
  # sadly, this won't have nice completion
  typeset -a args
  integer nextIsService=0 isfirst
  for i; do
    if [[ $i == -u ]]; then
      nextIsService=1
    else
      if [[ $nextIsService -eq 1 ]]; then
        nextIsService=0
        isfirst=1
        for g in $(journalctl --user -F _SYSTEMD_CGROUP|command grep -P "^/user\\.slice/user-$UID\\.slice/user@$UID\\.service/$i\."); do
          if [[ isfirst -eq 1 ]]; then
            args=($args _SYSTEMD_CGROUP=$g)
          else
            args=($args + _SYSTEMD_CGROUP=$g)
          fi
          isfirst=0
        done
        if [[ isfirst -eq 1 ]]; then
          args=($args USER_UNIT=$i.service)
        else
          args=($args + USER_UNIT=$i.service)
        fi
      else
        args=($args $i)
      fi
    fi
  done
  journalctl -n $((${LINES:=40} - 4)) --user ${^args}
}
alias privoxy_log="juser -u privoxy -a -f | ssed -R 's/(?<=\]:) [\d-]+ [\d:.]+ [\da-f]+//'"

# 后缀别名 {{{2
alias -s xsl="vim"
alias -s {html,htm}="firefox"
alias -s {pdf,ps,djvu}="evince"
alias -s ttf="gnome-font-viewer"
alias -s {png,jpg,gif}="feh"
alias -s jar="java -jar"

# 路径别名 {{{2
# hash -d directory="/path/to/your/long_long_directory :-)"

# 全局别名 {{{2
# 当前目录下最后修改的文件
# 来自 http://roylez.heroku.com/2010/03/06/zsh-recent-file-alias.html
alias -g NN="*(oc[1])"
alias -g NNF="*(oc[1].)"
alias -g NND="*(oc[1]/)"
alias -g NUL="/dev/null"
alias -g XS='"$(xsel)"'
alias -g ANYF='**/*[^~](.)'

# 函数 {{{1
# Place them in $_zdir/.zsh/functions
autoload zargs
autoload zmv

# load functions from  $_zdir/.zsh/functions/
source  $_zdir/.zsh/functions/* 

# smart cd function, allows switching to /etc when running 'cd /etc/fstab'
function cd () {
    if (( ${#argv} == 1 )) && [[ -f ${1} ]]; then
        [[ ! -e ${1:h} ]] && return 1
        print "Correcting ${1} to ${1:h}"
        builtin cd ${1:h}
    else
        builtin cd "$@"
    fi
}


# 变量设置 {{{1
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
          _current_branch=$(echo $_br|awk '$1 == "*" {print "%{\x1b[33m%} (" substr($0, 3) ")"}')
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
        _current_branch=$(echo $_br|awk '{if($1 == "*"){print "%{\x1b[33m%} (" substr($0, 3) ")"}}')
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
# 不同的 OS {{{2
if [[ $OS != *BSD ]]; then
  # FreeBSD 和 OpenBSD 上，MANPATH 会覆盖默认的配置
  [[ -d $HOME/.cabal/share/man ]] && export MANPATH=:$HOME/.cabal/share/man
elif [[ $OS = FreeBSD ]]; then
  export PAGER=less
fi

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

