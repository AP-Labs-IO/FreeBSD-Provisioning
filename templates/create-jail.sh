#!/bin/sh

set -e


BASTILLE_ROOT={{ bastille_prefix }}
DEFAULT_USERLAND="14.4-RELEASE"
DEFAULT_IP_OPTIONS="DHCP SLAAC"
TEMPLATES_REPO="git@gitlab.lan:ap-labs/bastille-templates.git"


usage() {
    cat << EOF >&2
create-jail-bastille.sh [options] <tempName> <targetName> <bridge> [extra arguments]

    Options:
        -u          -- Jail userland. Default: ${DEFAULT_USERLAND}.
        -i          -- IP options. Default: "${DEFAULT_IP_OPTIONS}".
        -T          -- Template to apply to the target jail.
        -F          -- Tree of extra files to copy into the target jail.
        -t          -- Tags to apply to the target jail, comma separated.
        -x          -- Enable debugging.
        -h          -- Print this usage message and exit.

    Mandatory arguments:
        tempName    -- Jail's temporary name.
        targetName  -- Jail's target name.
        bridge      -- Gateway bridge for the jail.

    Extra Arguments: List of ARG's applicable to the chosen jail template, in the form: --arg ARG1=value1 --arg ARG2=value2 (...).
EOF
}


while getopts ":u:i:T:F:t:xh" opt
do
    case $opt in
    u)
        userland=$OPTARG
        ;;
    i)
        ip_options=$OPTARG
        ;;
    T)
        template=$OPTARG
        ;;
    F)
        tree=$OPTARG
        ;;
    t)
        tags=$OPTARG
        ;;
    x)
        set -x
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -lt 3 ]
then
    echo "Not enough arguments, cannot continue!\n"
    usage
    exit 2
fi

tmp_name=$1
targe_name=$2
interface=$3
shift 3

: ${userland:="${DEFAULT_USERLAND}"}
: ${ip_options:="${DEFAULT_IP_OPTIONS}"}
: ${tmp_name:="${targe_name}"}

if bastille list ${targe_name} > /dev/null 2>&1
then
    echo "Jail \"${targe_name}\" already exists, cannot continue!"
    exit 3
fi
if bastille list ${tmp_name} > /dev/null 2>&1
then
    echo "Temporary jail \"${tmp_name}\" already exists, cannot continue!"
    exit 3
fi

bastille create --bridge --static-mac --clone ${tmp_name} ${userland} "${ip_options}" ${interface}
if [ "${tmp_name}" != "${targe_name}" ]
then
    bastille stop ${tmp_name}

    bastille rename ${tmp_name} ${targe_name}
    sed -i '' -E -e '/^ifconfig_e0b_.+_name/s/-/_/g' ${BASTILLE_ROOT}/jails/${targe_name}/root/etc/rc.conf
    rm -rf ${BASTILLE_ROOT}/jails/${tmp_name}

    bastille start ${targe_name}
fi

if [ -n "${template:-}" ]
then
    bastille bootstrap ${TEMPLATES_REPO}
    bastille template -a ${targe_name} ${template} $@
fi

if [ -n "${tree:-}" ]
then
    bastille cp ${targe_name} ${tree}/ /
fi

if [ -n "${tags:-}" ]
then
    bastille tags ${targe_name} add ${tags}
fi

exit $?
