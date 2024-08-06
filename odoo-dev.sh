#!/usr/bin/bash

# Check the number of arguments
if [ $# -gt 1 ]; then
    # If more than one argument is provided, display an error message and exit with status 1
    echo "Error: Only one argument can be passed, modules names can be provided as an argument."
    echo "Usage: $0 <module1,module2,...>"
    exit 1
elif [ $# -eq 1 ]; then
    echo "watch dog should be installed : pip3 install watchdog"
    # If exactly one argument is provided, update the specified modules
    MODULES="$1"
    echo "Updating and Testing modules: $MODULES"
    ./odoo-bin -c odoo.conf -u $MODULES --test-enable --test-tags=/$MODULES --load web,$MODULES --dev=all
else
    # If no arguments are provided, run Odoo without updating any module, only in custom_addons
    echo "No modules specified. Running Odoo without Updating or Testing any module."
    ./odoo-bin -c odoo.conf --dev=all
fi

