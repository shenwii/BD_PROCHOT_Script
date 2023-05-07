#!/bin/sh
set -e

INSTALL_DIR="/opt/bd_prochot_scipt"
MODULE_FILE="/etc/modules-load.d/msr.conf"
SERVICE_DIR="/etc/systemd/system"
BASE_DIR="$(dirname "$0")"

show_help() {
    cat >&2 <<EOF
Usage: setup.sh [OPTION]
  -i, --install         Install BD PROCHOT script
  -u, --uninstall       Uninstall BD PROCHOT script
EOF
    exit 1
}

root_check() {
    uid="$(id -u)"
    if [ "$uid" != 0 ]; then
        echo "Please run this script with root." >&2
        exit 1
    fi
}

install() {
    root_check
    echo "Please make sure that msr-tool is installed."
    mkdir -p "$INSTALL_DIR"
    cp "$BASE_DIR/bd_prochot_on.sh" "$INSTALL_DIR/bd_prochot_on.sh"
    chmod +x "$INSTALL_DIR/bd_prochot_on.sh"
    cp "$BASE_DIR/bd_prochot_off.sh" "$INSTALL_DIR/bd_prochot_off.sh"
    chmod +x "$INSTALL_DIR/bd_prochot_off.sh"
    if [ -f "$MODULE_FILE" ]; then
        mv "$MODULE_FILE" "${MODULE_FILE}.backup"
    fi
    echo 'msr' >"$MODULE_FILE"
    cp "$BASE_DIR/bd-prochot-off.service" "$SERVICE_DIR/bd-prochot-off.service"
    systemctl daemon-reload
    systemctl start bd-prochot-off.service
    systemctl enable bd-prochot-off.service
    echo "Installation completed."
}

uninstall() {
    root_check
    systemctl disable bd-prochot-off.service
    systemctl stop bd-prochot-off.service
    systemctl daemon-reload
    rm -f "$SERVICE_DIR/bd-prochot-off.service"
    rm -rf "$INSTALL_DIR"
    rm -f "$MODULE_FILE"
    if [ -f "${MODULE_FILE}.backup" ]; then
        mv "${MODULE_FILE}.backup" "$MODULE_FILE"
    fi
    echo "Uninstallation completed."
}

if [ $# = 0 ]; then
    show_help
fi

case "$1" in
    "-i" | "--intall")
        install
        ;;
    "-u" | "--unintall")
        uninstall
        ;;
    * )
        show_help
        ;;
esac
