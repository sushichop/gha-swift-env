#!/usr/bin/env bash

set -eu

SWIFT_VERSION=${1:='5.4.2'}   # e.g.'5.4.2' '5.5' '2021-12-23-a'

if ! ${GITHUB_ACTIONS}; then
  exit 1
fi

# Install Ninja.
if ! type ninja > /dev/null 2>&1; then
  sudo apt-get -q update && sudo apt-get -q install -y ninja-build
fi
ninja --version

# Remove the Swift minor version if it is 0.
if [[ ! $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  split_version=(${SWIFT_VERSION//./ })
  if [ ${#split_version[@]} -eq 3 ] && [ ${split_version[2]} -eq 0 ]; then
    SWIFT_VERSION=${split_version[0]}.${split_version[1]}
  fi
fi

# Check the Swift version whether it is already installed or not.
if `type swift > /dev/null 2>&1` && [[ $(swift --version | head -n 1) =~ " Swift version $SWIFT_VERSION " ]]; then
  echo "Swift ${SWIFT_VERSION} is already installed."
  swift --version
  exit 0
fi

# Get distribution info.
DISTRO_NAME=$(cat /etc/os-release | grep '^NAME=' | awk -F['='] '{print $2}' | sed -e 's/"//g')
DISTRO_VERSION_ID=$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F['='] '{print $2}' | sed -e 's/"//g')

if [ "${DISTRO_NAME}" != 'Ubuntu' ]; then
  echo 'unsupported distribution name'
  exit 1
fi

if [ "${DISTRO_VERSION_ID}" != '18.04' ] && [ "${DISTRO_VERSION_ID}" != '20.04' ]; then
  echo 'unsupported distribution version'
  exit 1
fi

DISTRO_NAME_LOWERCASE=$(echo "${DISTRO_NAME}" | tr "[:upper:]" "[:lower:]")
DISTRO_VERSION_ID_WO_DOT=$(echo "${DISTRO_VERSION_ID}" | sed -e 's/\.//g')

# Install Swift Toolchain.
if [[ $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  echo "Download Swift snapshot version: ${SWIFT_VERSION} ..."
  curl -sL "https://download.swift.org/development/${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID_WO_DOT}/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz" -o "/tmp/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz"
  tar xfz "/tmp/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz" -C /opt
  export PATH="/opt/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}/usr/bin:${PATH}"
  echo "/opt/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}/usr/bin" >> $GITHUB_PATH
else
  echo "Download Swift release version: ${SWIFT_VERSION} ..."
  curl -sL "https://download.swift.org/swift-${SWIFT_VERSION}-release/${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID_WO_DOT}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz" -o "/tmp/swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz"
  tar xfz "/tmp/swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}.tar.gz" -C /opt
  export PATH="/opt/swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}/usr/bin:${PATH}"
  echo "/opt/swift-${SWIFT_VERSION}-RELEASE-${DISTRO_NAME_LOWERCASE}${DISTRO_VERSION_ID}/usr/bin" >> $GITHUB_PATH
fi

# Output Swift version.
swift --version
