#!/usr/bin/env bash

set -eu

SWIFT_VERSION=${1:='5.4.2'}   # e.g.'5.4.2' '5.5' '2021-12-23-a'

if ! ${GITHUB_ACTIONS}; then
  exit 1
fi

# Install Ninja.
if ! type ninja > /dev/null 2>&1; then
  brew update && brew install ninja
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

# Install Swift Toolchain.
if [[ $SWIFT_VERSION =~ [0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z] ]]; then
  echo "Download Swift snapshot version: ${SWIFT_VERSION} ..."
  curl -sL "https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-osx.pkg" -o "/tmp/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-osx.pkg"
  xattr -dr "/tmp/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-osx.pkg"
  sudo installer -pkg "/tmp/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}-osx.pkg" -target LocalSystem
  export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}.xctoolchain/Info.plist")
  echo TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-${SWIFT_VERSION}.xctoolchain/Info.plist") >> $GITHUB_ENV
else
  echo "Download Swift release version: ${SWIFT_VERSION} ..."
  curl -sL "https://download.swift.org/swift-${SWIFT_VERSION}-release/xcode/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-osx.pkg" -o "/tmp/swift-${SWIFT_VERSION}-RELEASE-osx.pkg"
  xattr -dr "/tmp/swift-${SWIFT_VERSION}-RELEASE-osx.pkg"
  sudo installer -pkg "/tmp/swift-${SWIFT_VERSION}-RELEASE-osx.pkg" -target LocalSystem
  export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/swift-${SWIFT_VERSION}-RELEASE.xctoolchain/Info.plist")
  echo TOOLCHAINS=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier:' "/Library/Developer/Toolchains/swift-${SWIFT_VERSION}-RELEASE.xctoolchain/Info.plist") >> $GITHUB_ENV
fi

# Output Swift version.
swift --version
