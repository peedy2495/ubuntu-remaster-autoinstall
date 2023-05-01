#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

# This tool was made for hiding sensitive informations before committing.
# Refer these keys and paths for setting up your favours.


# redact ssh keys
sed -i 's/\(AAAA\).*/\1\<redacted\>"/' $exePath/www/autoinstall/nodes/user-data

# redact passwords
sed -i 's/\(password:\).*/\1 "\<redacted\>"/' $exePath/www/autoinstall/nodes/user-data
# redact domain setting
sed -i 's/\(domain=\).*/\1"example.com"/' $exePath/www/autoinstall/common/hostValues

# redact mac settings
sed -i 's/\(00:\).*/\1\<redacted\>/' $exePath/www/autoinstall/common/hostValues

# redact ip settings
sed -i 's/\(168.\).*/\1\<redacted\>/' $exePath/www/autoinstall/common/hostValues