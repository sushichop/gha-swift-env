Param(
  [String]$SwiftVersion = '5.4.2',  # e.g. '5.4.2' '5.5' '2021-12-23-a'
  [String]$Arch = 'x64',            #
  [String]$WinSDK = ''              # e.g. '', '10.019041.0', '10.0.20348.0'
)

if (!$Env:GITHUB_ACTIONS) {
  return 1
}
$PSVersionTable


### Ninja

# Install Ninja.
choco install ninja --yes --no-progress
ninja --version


### Swift Toolchain

# Remove the Swift minor version if it is 0.
if (-Not($SwiftVersion -match '\d{4}-\d{2}-\d{2}-\D')) {
  $SplitVersion = $SwiftVersion.Split('.')
  if (($SplitVersion.Length -eq 3) -and ($SplitVersion[2] -eq 0)) {
    $SwiftVersion = $SplitVersion[0] + '.' + $SplitVersion[1]
  }
}

# Check the Swift version whether it is already installed or not.
if ($NULL -ne (Get-Command swift -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition -First 1)) {
  $CommandResult = swift --version | Select-Object -First 1
  if ($CommandResult -cmatch " Swift version $SwiftVersion ") {
    Write-Output "Swift $SwiftVersion is already installed."
    swift --version
    exit 0
  }
}

# Install Swift Toolchain.
$exitCode = 0
if ($SwiftVersion -match '\d{4}-\d{2}-\d{2}-\D') {
  Write-Output "Download Swift snapshot version: $SwiftVersion ..."
  curl.exe -sL "https://download.swift.org/development/windows10/swift-DEVELOPMENT-SNAPSHOT-$SwiftVersion/swift-DEVELOPMENT-SNAPSHOT-$SwiftVersion-windows10.exe" -o "$Env:TEMP/swift-DEVELOPMENT-SNAPSHOT-$SwiftVersion-windows10.exe"
  Write-Output "🎉 Successfully downloaded!"
  $process = Start-Process -FilePath "$Env:TEMP/swift-DEVELOPMENT-SNAPSHOT-$SwiftVersion-windows10.exe" -ArgumentList -q -Wait -PassThru
  $exitCode = $process.ExitCode
} else {
  Write-Output "Download Swift release version: $SwiftVersion ..."
  curl.exe -sL "https://download.swift.org/swift-$SwiftVersion-release/windows10/swift-$SwiftVersion-RELEASE/swift-$SwiftVersion-RELEASE-windows10.exe" -o "$Env:TEMP/swift-$SwiftVersion-RELEASE-windows10.exe"
  Write-Output "🎉 Successfully downloaded!"
  $process = Start-Process -FilePath "$Env:TEMP/swift-$SwiftVersion-RELEASE-windows10.exe" -ArgumentList  -q -Wait -PassThru
  $exitCode = $process.ExitCode
}
if (($exitCode -eq 0) -or ($exitCode -eq 3010)) {
  Write-Output "🎉 Successfully installed!"
} else {
  Write-Output "🚫 Failed to install..."
  exit $exitCode
}

# Get environment variables in the current session.
foreach($level in 'Machine', 'User') {
  [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
     if($_.Name -eq 'Path') { 
        $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select-Object -unique) -join ';'
     }
     $_
  } | Set-Content -Path { "Env:$($_.Name)" }
}

# Set environment variables.
Write-Output "$Env:Path" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8
Get-ChildItem Env: | ForEach-Object { Write-Output "$($_.Name)=$($_.Value)" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append }


### Visual Studio

# Set up Visual Studio.
$InstallationPath = Get-VSSetupInstance | Select-Object -ExpandProperty InstallationPath
$vcvarsallPath = Join-Path $InstallationPath 'VC\Auxiliary\Build\vcvarsall.bat'

cmd.exe -Verb runas /c "call `"$vcvarsallPath`" $Arch $WinSDK && set > %TEMP%\vcvars.txt"

Get-Content "$Env:TEMP\vcvars.txt" | Foreach-Object {
  if ($_ -match "^(.*?)=(.*)$") {
    $key=$matches[1].ToString()
    $value=$matches[2].ToString()
    # Sets environment variables for this step.
    switch ($key) {
      'Path'                { $Env:Path = $value + ';' + $Env:Path }
      'UniversalCRTSdkDir'  { $Env:UniversalCRTSdkDir = $value }
      'UCRTVersion'         { $Env:UCRTVersion = $value }
      'VCToolsInstallDir'   { $Env:VCToolsInstallDir = $value }
      Default               { }
    }
    # Sets environments variables for subsequent steps(not this step).
    if ($key -eq 'Path') {
      Write-Output "$Env:Path" | Out-File -FilePath $Env:GITHUB_PATH -Encoding utf-8 -Append
    } else {
      Write-Output "$key=$value" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
    }
  }
}

Write-Output $Env:Path
Write-Output $Env:UniversalCRTSdkDir
Write-Output $Env:UCRTVersion
Write-Output $Env:VCToolsInstallDir


# Add supporting files.
Copy-Item -Path "$Env:SDKROOT\usr\share\ucrt.modulemap" -Destination "$Env:UniversalCRTSdkDir\Include\$Env:UCRTVersion\ucrt\module.modulemap" -Force
if (Test-Path -Path "$env:SDKROOT\usr\share\vcruntime.modulemap") {
  Copy-Item -Path "$env:SDKROOT\usr\share\vcruntime.modulemap" -Destination "$env:VCToolsInstallDir\include\module.modulemap" -Force
  Copy-Item -Path "$env:SDKROOT\usr\share\vcruntime.apinotes" -Destination "$env:VCToolsInstallDir\include\vcruntime.apinotes" -Force
} else {
  Copy-Item -Path "$Env:SDKROOT\usr\share\visualc.modulemap" -Destination "$Env:VCToolsInstallDir\include\module.modulemap" -Force
  Copy-Item -Path "$Env:SDKROOT\usr\share\visualc.apinotes" -Destination "$Env:VCToolsInstallDir\include\visualc.apinotes" -Force
}
Copy-Item -Path "$Env:SDKROOT\usr\share\winsdk.modulemap" -Destination "$Env:UniversalCRTSdkDir\Include\$Env:UCRTVersion\um\module.modulemap" -Force

# Output Swift version.
swift --version
