param(
    [switch]
    $Clean,
    [switch]
    $Debug
)
if ($Debug) {
    $PreviousDebug = $DebugPreference
    $DebugPreference = 'Continue'
}
$PrevDir = Get-Location
Set-Location $PSScriptRoot

function TimeCode {
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
}

if ($Clean) {
    Write-Host "$(TimeCode) Executing task: clean"

    Remove-Item -Recurse -Force .\build\
    Write-Host "$(TimeCode) Removed directory: build"
    
    Write-Host "$(TimeCode) Completed task: clean"
    if ($Debug) {
        $DebugPreference = $PreviousDebug
    }
    return
}

Write-Host "$(TimeCode) Executing task: build"

$Modlist = [System.IO.File]::ReadLines("$(Resolve-Path .\pack\)modlist.html") | Sort-Object
$Modlist[0] = '<ul>'
$Modlist[$Modlist.Length - 1] = '</ul>'
$Modlist = $Modlist -join("`n")
$Modlist > .\pack\modlist.html
Write-Host "$(TimeCode) Sorted mod list."

# $Readme = Get-Content .\src\README-template.md -Raw
# $Readme = $Readme.Replace('<!-- MODLIST -->', ($Modlist))
# $Readme > .\README.md
# Write-Host "$(TimeCode) Generated README from template."

[System.IO.Directory]::CreateDirectory('.\build\') | Out-Null
Write-Debug "$(TimeCode) Created directory: $(Resolve-Path .\build\)"
[System.IO.Directory]::CreateDirectory('.\build\artifact\') | Out-Null
Write-Debug "$(TimeCode) Created directory: $(Resolve-Path .\build\artifact\)"

if ($null -eq (Get-Command '7z' -ErrorAction SilentlyContinue)) {
    Write-Error "$(TimeCode) `"7z`" was not found in PATH."
    Write-Host "$(TimeCode) Stopping due to errors."
    return
}
if ($null -eq (Get-Command 'jq' -ErrorAction SilentlyContinue)) {
    Write-Error "$(TimeCode) `"jq`" was not found in PATH."
    Write-Host "$(TimeCode) Stopping due to errors."
    return
}
if ($null -eq (Get-Command 'rg' -ErrorAction SilentlyContinue)) {
    Write-Error "$(TimeCode) `"rg`" was not found in PATH."
    Write-Host "$(TimeCode) Stopping due to errors."
    return
}

$Manifest = (jq '.files|=sort_by(.projectID)' .\pack\manifest.json) -join("`n")
$Manifest > .\pack\manifest.json
$Manifest = Get-Content .\pack\manifest.json -Raw | ConvertFrom-Json
Write-Host "$(TimeCode) Found artifact name: $($Manifest.name)"
Write-Host "$(TimeCode) Found artifact version: $($Manifest.version)"

$Template = @{
    modlist = $Modlist
    version = $Manifest.version
}
$Pattern = [regex]'<!-- ([A-Z]+) -->'
rg '<!-- ([A-Z]+) -->' .\src\template\ --files-with-matches | ForEach-Object {
    $Content = Get-Content $_

    for ($i = 0; $i -lt $Content.Length; $i++) {
        $Content[$i] = $Pattern.Replace($Content[$i], {
            param($Match)
            $Key = ($Match.Groups[1].Value).ToLower()
            Write-Debug "$(TimeCode) Replaced '$Key' on line $($i + 1) of $(Resolve-Path $_)"
            $Template.$Key
        })
    }
    $Content > (Resolve-Path $_.Replace('src\template\', ''))

    Write-Host "$(TimeCode) Generated from template: $(Resolve-Path $_.Replace('src\template\', ''))"
}

$ArtifactName = "$($Manifest.name)-v$($Manifest.version)".Replace(' ', '-')
if (Test-Path "$(Resolve-Path .\build\artifact\)$ArtifactName.zip") {
    Remove-Item -Force "$(Resolve-Path .\build\artifact\)$ArtifactName.zip"
}
7z u "$(Resolve-Path .\build\artifact\)$ArtifactName.zip" "$(Resolve-Path .\pack\)*" | Out-Null
Write-Host "$(TimeCode) Created artifact: $(Resolve-Path .\build\artifact\)$ArtifactName.zip"

Write-Host "$(TimeCode) Completed task: build"

Set-Location $PrevDir
if ($Debug) {
    $DebugPreference = $PreviousDebug
}
