#!/bin/bash

SCRIPT="spec.sh"
COMMAND="spec"
INSTALL_DIR="/usr/local/bin"

if [[ ! -d $INSTALL_DIR ]]; then
  mkdir -p $INSTALL_DIR
fi

# Copy Script and make soft link
cp $SCRIPT $INSTALL_DIR

if [[ -e $($INSTALL_DIR/$SCRIPT $INSTALL_DIR/$COMMAND) ]]; then
	echo ""	
else
	ln -s $INSTALL_DIR/$SCRIPT $INSTALL_DIR/$COMMAND
fi

# Add Execute Permission
chmod +x $INSTALL_DIR/$SCRIPT
chmod +x $INSTALL_DIR/$COMMAND

# Add Path to profile
echo 'export PATH="$PATH":$INSTALL_DIR' >> ~/.profile
source ~/.profile
