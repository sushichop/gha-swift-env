# gha-swift-env

![CI](https://github.com/sushichop/gha-swift-env/workflows/CI/badge.svg)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sushichop/gha-swift-env/blob/main/LICENSE)

`gha-swift-env` is a GitHub Action that sets up a Swift environment for **cross-platform(macOS, Ubuntu Linux, and Windows)**. 

And it also automatically installs Ninja, which is required for building a Swift code with CMake.

## Usage

You can set the Swift version of the release.

```yaml
- uses: sushichop/gha-swift-env@v1
  with:
    swift-version: '5.4.2'
- name: Show Swift version and build a Swift package
  run: |
    swift --version
    swift build -v
```

You can also set the Swift version of the snapshot.

```yaml
- uses: sushichop/gha-swift-env@v1
  with:
    swift-version: '2021-12-23-a'
- name: Show Swift version and build a Swift package
  run: |
    swift --version
    swift build -v
```

## Example

You can build and test a Swift package on cross-platform(macOS, Ubuntu Linux, and Windows).


```yaml
on
  pull_request:

jobs:
  swiftpm:
    name: SwiftPM - Swift ${{ matrix.swift-version }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        swift-version: ['5.4.2', '2021-12-23-a']
        os: ['macos-latest', 'ubuntu-latest', 'windows-latest']
      fail-fast: false
    steps:
      - uses: actions/checkout@v2
      - uses: sushichop/gha-swift-env@V1
        with:
          swift-version: ${{ matrix.swift-version }}
      - name: Build and test a Swift package
        run: |
          swift build -v
          swift test -v
```

You can also build a Swift package with CMake and Ninja.

```yaml
- uses: sushichop/gha-swift-env@v1
  with:
    swift-version: '5.4.2'
- name: Build with CMake and Ninja
  run: |
    cmake -B ./build -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=Debug -G Ninja -S .
    ninja -C ./build -v
```

## Inputs

- `swift-version` – (required) Swift version to use
  - Specify release or snapshot version
    - `'5.4.2'`, `'5.5'`, `'2021-12-23-a'`, ...
  - Default
    - `'5.4.2'`
    - This value is the minimum Swift version to support Swift 
    package on cross-platform
   
- `winsdk-version` – (optional) WinSDK to use on Windows
  - Specify Windows 10 SDK version
    - `'default'`, `'10.019041.0'`, `'10.0.20348.0'`, ... 
  - Default:
    - `default`
    - This value(`default`) sets the default Windows 10 SDK version

## License

`gha-swift-env` is available under the [MIT license](http://www.opensource.org/licenses/mit-license). See the LICENSE file for details.

