# vim:se ft=zsh:
TRAPTERM () { exit }
function update () { . $_zdir/.zshrc }
if (( $+commands[vimtrace] )); then
  (( $+commands[strace] )) && alias strace='vimtrace strace'
  (( $+commands[ltrace] )) && alias ltrace='vimtrace ltrace'
else
  (( $+commands[strace] )) && function strace () { (command strace "$@" 3>&1 1>&2 2>&3) | vim -R - }
  (( $+commands[ltrace] )) && function ltrace () { (command ltrace "$@" 3>&1 1>&2 2>&3) | vim -R - }
fi
nocolor () { sed -r 's:\x1b\[[0-9;]*[mK]::g;s:[\r\x0f]::g' }
sshpubkey () { tee < ~/.ssh/id_*.pub(om[1]) >(xsel -i) }
rmempty () { #删除空文件 {{{2
  for i; do
    [[ -f $i && ! -s $i ]] && rm $i
  done
  return 0
}
breakln () { #断掉软链接 {{{2
  for f in $*; do
    tgt=$(readlink "$f")
    unlink "$f"
    cp -rL "$tgt" "$f"
  done
}
if [[ $TERM == screen* || $TERM == tmux* ]]; then # {{{2 设置标题
  # 注：不支持中文
  title () { echo -ne "\ek$*\e\\" }
else
  title () { echo -ne "\e]0;$*\a" }
fi
if [[ $TERM == xterm* || $TERM == *rxvt* ]]; then # {{{2 设置光标颜色
  cursorcolor () { echo -ne "\e]12;$*\007" }
elif [[ $TERM == screen* ]]; then
  if (( $+TMUX )); then
    cursorcolor () { echo -ne "\ePtmux;\e\e]12;$*\007\e\\" }
  else
    cursorcolor () { echo -ne "\eP\e]12;$*\007\e\\" }
  fi
elif [[ $TERM == tmux* ]]; then
  cursorcolor () { echo -ne "\ePtmux;\e\e]12;$*\007\e\\" }
fi
if [[ -d ${VIMTMP:=~/tmpfs} ]]; then # {{{2 record errors from compilers
  # problems:
  #   stdout & stderr mixed
  #   return code
  _error_command () {
    eval "
      $1 () {
        errfile=\$VIMTMP/.error
        ptyrun command $@ \"\$@\" > >(tee >(nocolor >\$errfile))
      }
    "
  }
  # _error_command gcc -g -Wall
  # _error_command g++ -g -Wall
  # _error_command cargo
fi
ptyrun () { # 使用伪终端代替管道，对 ls 这种“顽固分子”有效 {{{2
  local ptyname=pty-$$
  zmodload zsh/zpty
  zpty $ptyname "${(q)@}"
  if [[ ! -t 1 ]]; then
    setopt local_traps
    trap '' INT
  fi
  zpty -r $ptyname
  zpty -d $ptyname
}
ptyless () {
  ptyrun "$@" | tr -d $'\x0f' | less
}
clipboard2qr () { # 剪贴板数据到QR码 {{{2
  data="$(xsel)"
  echo $data
  echo $data | qrencode -t UTF8
}
screen2clipboard () { # 截图到剪贴板 {{{2
  screenshot | xclip -i -selection clipboard -t image/png
}
clipboard_bmp2png () { # 将剪贴板中的图片从 bmp 转到 png。QQ 会使用 bmp
  xclip -selection clipboard -o -t image/bmp | convert - png:- | xclip -i -selection clipboard -t image/png
}
clipboard_png2bmp () { # 将剪贴板中的图片从 png 转到 bmp。QQ 会使用 bmp
  xclip -selection clipboard -o -t image/png | convert - bmp:- | xclip -i -selection clipboard -t image/bmp
}
mvgb () { # 文件名从 GB 转码，带确认{{{2
  for i in $*; do
    new="`echo $i|iconv -f utf8 -t latin1|iconv -f gbk`"
    echo $new
    echo -n 'Sure? '
    read -q ans && mv -i $i $new
    echo
  done
}
pid () { #{{{2
  s=0
  for i in $*; do
    i=${i/,/}
    echo -n "$i: "
    r=$(cat /proc/$i/cmdline|tr '\0' ' ' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo not found
      s=1
    else
      echo $r
    fi
  done
  return $s
}
# s () { 快速查找当前目录下的文件 {{{2
# rg is 3x faster than ag, and find 2x
if (( $+commands[rg] )) then
  s () {
    rg --files -g "*$1*"
  }
else
  s () {
    find . -name "*$1*"
  }
fi
killssh () { #{{{2 kill ssh that using default master socket
  local keys
  if [[ $# -lt 1 ]]; then
    keys=('')
  else
    keys=$@
  fi

  for key in "${keys[@]}"; do
    local pids="$(netstat -nxlp 2>/dev/null | awk -v dir=$(_killssh_dir) -v key=$key \
      '{if(index($NF, dir"/master-"key) == 1){print $9}}' | grep -o '^[[:digit:]]\+')"
    [[ -n $pids ]] && kill ${=pids}
  done
}

_killssh_dir () {
  local dir
  if [[ -n $XDG_RUNTIME_DIR && -d $XDG_RUNTIME_DIR/ssh ]]; then
    dir=$XDG_RUNTIME_DIR/ssh
  else
    dir=$HOME/.ssh
  fi
  print $dir
}

_killssh_items () {
  netstat -nxlp 2>/dev/null | awk -v dir=$(_killssh_dir) \
    'BEGIN{P=dir"/master-";L=length(P);}{if(index($NF, P) == 1){a=substr($NF,L+1);sub(/\.[[:alnum:]]+$/,"",a);print a}}'
}

_killssh () {
  _arguments \
    ':what:($(_killssh_items))'
  return 0
}
compdef _killssh killssh
xmpphost () { #{{{2 query XMPP SRV records
  host -t SRV _xmpp-client._tcp.$1
  host -t SRV _xmpp-server._tcp.$1
}
tianqi () { #天气预报 {{{2
  local city
  if [[ $# -eq 1 ]]; then
    city=$1
  elif [[ $# -eq 0 ]]; then
    city=北京
  else
    echo "城市？" >&2
    return 1
  fi
  w3m -dump "http://weather1.sina.cn/dpool/weather_new/forecast_new.php?city=$city&vt=4" 2>/dev/null | sed '1,/更换城市/d;/^loading/,$d;s/\[[^]]\+\]//g'
}
duppkg4repo () { #软件仓库中重复的软件包 {{{2
  local repo=$1
  [[ -z $repo ]] && { echo >&2 'which repository to examine?'; return 1 }
  local pkgs
  pkgs=$(comm -12 \
    <(pacman -Sl $repo|awk '{print $2}'|sort) \
    <(pacman -Sl|awk -vrepo=$repo '$1 != repo {print $2}'|sort) \
  )
  [[ -z $pkgs ]] && return 0
  LANG=C pacman -Si ${=pkgs} | awk -vself=$repo '/^Repository/{ repo=$3; } /^Name/ && repo != self { printf("%s/%s\n", repo, $3); }'
}
try_until_succeed () { #反复重试，直到成功 {{{2
  while ! $*; do :; done
}
test_url_resolves_to () { # {{{2
  url=$1
  ip=$2
  host=${${url#*//}%%/*}
  curl -v -i --resolve $host:80:$ip --resolve $host:443:$ip $url
}
install_autojump () { # autojump 快速安装 {{{2
  mkdir -p ~/.local/bin ${_zdir}/.zsh/Completion
  pushd ~/.local/bin > /dev/null
  wget -N https://github.com/joelthelion/autojump/raw/master/bin/autojump{,_{data,argparse,utils}.py}
  chmod +x autojump
  popd > /dev/null
  wget https://github.com/joelthelion/autojump/raw/master/bin/autojump.zsh -O ${_zdir}/.zsh/autojump.zsh
  wget https://github.com/joelthelion/autojump/raw/master/bin/_j -O ${_zdir}/.zsh/Completion/_j
}
wait_pid () { # {{{2
  local pid=$1
  while true; do
    if [[ -d /proc/$pid ]]; then
      sleep 3
    else
      break
    fi
  done
}