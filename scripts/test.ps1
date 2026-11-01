$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$lua = Join-Path $env:USERPROFILE "scoop\apps\lua\current\lua55.exe"
$busted = Join-Path $root ".luarocks\lib\luarocks\rocks-5.5\busted\2.3.0-1\bin\busted"
$luaPath = (Join-Path $root ".luarocks\share\lua\5.5\?.lua") + ";" +
    (Join-Path $root ".luarocks\share\lua\5.5\?\init.lua") + ";" +
    (Join-Path $root "?.lua") + ";" +
    (Join-Path $root "?\init.lua") + ";;"
$luaCPath = (Join-Path $root ".luarocks\lib\lua\5.5\?.dll") + ";;"

if (-not (Test-Path $lua)) {
    throw "Lua 5.5 was not found. Install it with: scoop install lua"
}

if (-not (Test-Path $busted)) {
    throw "Busted was not found. Install the project dependencies before testing."
}

Push-Location $root
try {
    & $lua -e "package.path=[[$luaPath]]; package.cpath=[[$luaCPath]]" $busted @args
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
