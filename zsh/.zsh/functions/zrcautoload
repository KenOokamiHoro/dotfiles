
# autoload wrapper - use this one instead of autoload directly
# We need to define this function as early as this, because autoloading
# 'is-at-least()' needs it.
function zrcautoload () {
    emulate -L zsh
    setopt extended_glob
    local fdir ffile
    local -i ffound

    ffile=$1
    (( ffound = 0 ))
    for fdir in ${fpath} ; do
        [[ -e ${fdir}/${ffile} ]] && (( ffound = 1 ))
    done

    (( ffound == 0 )) && return 1
    if [[ $ZSH_VERSION == 3.1.<6-> || $ZSH_VERSION == <4->* ]] ; then
        autoload -U ${ffile} || return 1
    else
        autoload ${ffile} || return 1
    fi
    return 0
}

# The following is the ‘add-zsh-hook’ function from zsh upstream. It is
# included here to make the setup work with older versions of zsh (prior to
# 4.3.7) in which this function had a bug that triggers annoying errors during
# shell startup. This is exactly upstreams code from f0068edb4888a4d8fe94def,
# with just a few adjustments in coding style to make the function look more
# compact. This definition can be removed as soon as we raise the minimum
# version requirement to 4.3.7 or newer.
function add-zsh-hook () {
    # Add to HOOK the given FUNCTION.
    # HOOK is one of chpwd, precmd, preexec, periodic, zshaddhistory,
    # zshexit, zsh_directory_name (the _functions subscript is not required).
    #
    # With -d, remove the function from the hook instead; delete the hook
    # variable if it is empty.
    #
    # -D behaves like -d, but pattern characters are active in the function
    # name, so any matching function will be deleted from the hook.
    #
    # Without -d, the FUNCTION is marked for autoload; -U is passed down to
    # autoload if that is given, as are -z and -k. (This is harmless if the
    # function is actually defined inline.)
    emulate -L zsh
    local -a hooktypes
    hooktypes=(
        chpwd precmd preexec periodic zshaddhistory zshexit
        zsh_directory_name
    )
    local usage="Usage: $0 hook function\nValid hooks are:\n  $hooktypes"
    local opt
    local -a autoopts
    integer del list help
    while getopts "dDhLUzk" opt; do
        case $opt in
        (d) del=1 ;;
        (D) del=2 ;;
        (h) help=1 ;;
        (L) list=1 ;;
        ([Uzk]) autoopts+=(-$opt) ;;
        (*) return 1 ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    if (( list )); then
        typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
        return $?
    elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 )); then
        print -u$(( 2 - help )) $usage
        return $(( 1 - help ))
    fi
    local hook="${1}_functions"
    local fn="$2"
    if (( del )); then
        # delete, if hook is set
        if (( ${(P)+hook} )); then
            if (( del == 2 )); then
                set -A $hook ${(P)hook:#${~fn}}
            else
                set -A $hook ${(P)hook:#$fn}
            fi
            # unset if no remaining entries --- this can give better
            # performance in some cases
            if (( ! ${(P)#hook} )); then
                unset $hook
            fi
        fi
    else
        if (( ${(P)+hook} )); then
            if (( ${${(P)hook}[(I)$fn]} == 0 )); then
                set -A $hook ${(P)hook} $fn
            fi
        else
            set -A $hook $fn
        fi
        autoload $autoopts -- $fn
    fi
}
