#!/usr/bin/bash
OS_TYPE='manjaro'
MIN_VERSION='v0.9'
SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})
PLUGINS_DIR=${SCRIPT_DIR}/../share/nvcode/lazy

function usage()
{
    echo "Usage:"
    echo "      $(basename $0) [-i | -u]"
    echo ""
    echo "  -i, --install      install neovim and plugins"
    echo "  -u, --uninstall    uninstall plugins"
    exit -1
}

#######################################
# 参数解析
# Arguments:
#   $*
#######################################
function parser_param()
{
    while [ $# != 0 ]
    do
        case $1 in
            -i|--install)
                is_install=1
                shift
                ;;
            -u|--uninstall)
                is_uninstall=1
                shift
                ;;
            *)
                echo "Invalid parameter"
                usage
                ;;
        esac
    done
}

#######################################
# 判断命令是否存在
# Arguments:
#   $1
# return:
#   0 不存在
#   1 存在
#######################################
function is_exists()
{
    type $1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        return 1
    fi
    return 0
}

#######################################
# 判断版本号大小
# Arguments:
#   $1
#   $2
#######################################
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" != "$1"; }

function get_os_type()
{
    echo $(cat /etc/os-release | grep ^ID= | awk -F '=' '{print $2}' | awk '{print tolower($0)}')
}

function manjaro_install_requirements()
{
    sudo pacman -S wget --noconfirm
    sudo pacman -S unzip --noconfirm
    sudo pacman -S cmake --noconfirm
    sudo pacman -S make --noconfirm
    sudo pacman -S gcc --noconfirm
    sudo pacman -S translate-shell --noconfirm
    sudo pacman -S lazygit --noconfirm
    sudo pacman -S bash-language-server --noconfirm
    sudo pacman -S pyright --noconfirm
    sudo pacman -S lua-language-server --noconfirm
    sudo pacman -S go --noconfirm
    sudo pacman -S gopls --noconfirm
    sudo pacman -S npm --noconfirm
    sudo pacman -S ripgrep --noconfirm
    sudo pacman -S fd --noconfirm
    sudo pacman -S xsel --noconfirm
    sudo pacman -S noto-fonts-emoji --noconfirm
    sudo pacman -S zathura --noconfirm
    sudo pacman -S fzf --noconfirm
    yay -S jdtls --noconfirm
}

function arch_install_requirements()
{
    manjaro_install_requirements
}

function install_requirements()
{
    ${OS_TYPE}_install_requirements
    [ $? -eq 0 ] || exit 1

    wget https://github.com/microsoft/vscode-cpptools/releases/download/v1.10.8/cpptools-linux.vsix
    mkdir vscode-cpptools
    pushd vscode-cpptools
    unzip ../cpptools-linux.vsix
    popd
    mv vscode-cpptools ~/.local/
    chmod +x  ~/.local/vscode-cpptools/extension/debugAdapters/bin/OpenDebugAD7
    rm -f cpptools-linux.vsix
}

function install_fonts()
{
    ${SCRIPT_DIR}/install_fonts.sh
    [ $? -eq 0 ] || exit 1
    exit 0
}

function build_luasnip()
{
    pushd ${PLUGINS_DIR}/LuaSnip
        make install_jsregexp
    popd 
}

function build_fzf_native()
{
    pushd ${PLUGINS_DIR}/telescope-fzf-native.nvim
        make clean && make 
    popd 
}

function build_tabnine()
{
    pushd ${PLUGINS_DIR}/tabnine-nvim
        ./dl_binaries.sh
    popd
}

function build_plugins()
{
    build_luasnip
    build_fzf_native
    build_tabnine
}

function main()
{
    is_install=0
    is_uninstall=0
    install_path="$HOME/.local/nvcode"
    is_install_fonts="Y"
    is_install_requires="N"

    # parser parameter
    if [ $# -eq 0 ]; then usage; fi
    parser_param $*

    read -p "Enter installation path [default: $HOME/.local/nvcode]: " install_path
    read -p "Install fonts to support icon fonts? (Y/N)[default: Y]: " is_install_fonts
    read -p "Are the dependencies installed? (Y/N)[default: N]" is_install_requires

    # get type of os
    OS_TYPE=$(get_os_type)
    echo "OS: ${OS_TYPE}"

    # install neovim and plugin
    if [ ${is_install} -eq 1 ]
    then
        echo "Begin ..."
        if [ "x"$is_install_requires = "xY" -o "x"$is_install_requires = "xy" ]
        then
            install_requirements
            [ $? -eq 0 ] || exit 1
        fi

        if [ "x"$is_install_fonts = "xY" -o "x"$is_install_fonts = "xy" ]
        then
            install_fonts
            [ $? -eq 0 ] || exit 1
        fi

        if [ -d $install_path ]
        then
            echo "Error: The installation directory already exists."
            exit 1
        fi

        mkdir -p $install_path
        tar xzf nvcode.tar.gz -C $install_path

        PLUGINS_DIR=${install_path}/share/nvcode/lazy
        build_plugins
        echo "Finished!!"
        echo "Add the path $install_path to the PATH variable."
    fi
}

main $*
