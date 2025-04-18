#!/bin/bash

# Show all installed packages
#emerge -epv @world

# Search new packages
#emerge -s somepackagename

# Remove package and clear dependecies
#emerge --deselect app-editors/emacs
# Clear dependencies
#emerge -a --depclean

# Update all existing packages if USE flags was changed
emerge --ask --verbose --update --changed-use --deep -b @world

