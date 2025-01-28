# gha-swift-env

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-v1-undefined.svg?logo=github&logoColor=white)](https://github.com/marketplace/actions/swift-env)
[![release](https://img.shields.io/github/v/release/sushichop/gha-swift-env.svg?color=blue)](https://github.com/sushichop/gha-swift-env/releases)
![CI](https://github.com/sushichop/gha-swift-env/workflows/CI/badge.svg)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sushichop/gha-swift-env/blob/main/LICENSE)

`gha-swift-env` is a GitHub Action that sets up Swift environment for **cross-platform(macOS, Ubuntu Linux, and Windows)**. 

## Usage

You can set the release version of Swift.

```yaml
- uses: sushichop/gha-swift-env@v1
  with:
    swift-version: '6.0.3'
- name: Show Swift version and build Swift package
  run: |
    swift --version
    swift build -v -c release
```

You can also set the snapshot version of Swift.

```yaml
- uses: sushichop/gha-swift-env@v1
  with:
    swift-version: '2025-01-10-a'
- name: Show Swift version and build Swift package
  run: |
    swift --version
    swift build -v -c release
```

## Example

You can build and test Swift package for cross-platform(macOS, Ubuntu Linux, and Windows).


```yaml
on
  pull_request:

jobs:
  swiftpm:
    name: SwiftPM - Swift ${{ matrix.swift-version }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: ['macos-14', 'ubuntu-22.04', 'windows-2022']
        swift-version: ['6.0.3', '5.10', '2025-01-10-a']
      fail-fast: false
    steps:
      - uses: actions/checkout@v4
      - uses: sushichop/gha-swift-env@V1
        with:
          swift-version: ${{ matrix.swift-version }}
      - name: Build and test a Swift package
        run: |
          swift build -v -c release
          swift test -v -Xswiftc -warnings-as-errors
```

## Inputs

- `swift-version` – (required) Swift version to use
  - Specify release or snapshot version
    - `'5.10'`, `'6.0.3'`, `'2025-01-10-a'`, ...
  - Default
    - `'6.0.3'`

- `winsdk-version` – (optional) WinSDK to use on Windows
  - Specify Windows 10 SDK version
    - `''`, `'10.0.26100.0'`, ... 
  - Default:
    - `''`
    - This value(an empty string) sets the default Windows 10 SDK version

## License

`gha-swift-env` is available under the [MIT license](http://www.opensource.org/licenses/mit-license). See the LICENSE file for details.

