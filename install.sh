#!/bin/bash

import_key() {
    # Verify the public key fingerprint
    fingerprint="4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD"
    fingerprint_verified=false

    echo "Please verify the fingerprint of the key.asc:"
    fingerprint_output=$(curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint)

    if [[ $fingerprint_output == *"$fingerprint"* ]]; then
        fingerprint_verified=true
    fi

    if $fingerprint_verified; then
        # Save the public key locally
        mkdir -p /etc/apt/keyrings/
        curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc

        echo "Key saved locally."
    else
        echo "Fingerprint does not match. Aborting..."
        exit 1
    fi
}

add_stable_repository() {
    # Add the Stable version repository
    cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF

    echo "Stable repository added."
}

add_daily_repository() {
    # Add the Daily version repository
    cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-daily.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/daily
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF

    echo "Daily repository added."
}

install_incus() {
    # Update the software source list
    apt-get update -y

    # Install Incus
    apt-get install incus -y

    echo "Incus installed."
}

# Verify if the fingerprint matches
fingerprint="4EFC 5906 96CB 15B8 7C73  A3AD 82CC 8797 C838 DCFD"
fingerprint_output=$(curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint)

if [[ $fingerprint_output == *"$fingerprint"* ]]; then
    import_key
    add_stable_repository
    install_incus
    exit 0
else
    echo "Fingerprint does not match. Aborting..."
    exit 1
fi
