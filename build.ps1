param(
    [switch]
    $Clean
)
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
    return
}

Write-Host "$(TimeCode) Executing task: build"

$Modlist = [System.IO.File]::ReadLines("$(Resolve-Path .\pack\)modlist.html") | Sort-Object
$Modlist[0] = '<ul>'
$Modlist[$Modlist.Length - 1] = '</ul>'
$Modlist > .\pack\modlist.html
Write-Host "$(TimeCode) Sorted mod list."

$Readme = Get-Content .\src\README-template.md -Raw
$Readme = $Readme.Replace('<!-- MODLIST -->', ($Modlist))
$Readme > .\README.md
Write-Host "$(TimeCode) Generated README from template."

[System.IO.Directory]::CreateDirectory('.\build\') | Out-Null
Write-Debug "$(TimeCode) Created directory: build"
[System.IO.Directory]::CreateDirectory('.\build\artifact\') | Out-Null
Write-Debug "$(TimeCode) Created directory: build/artifact"

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

$Manifest = (jq '.files|=sort_by(.projectID)' .\pack\manifest.json) -join("`n")
$Manifest > .\pack\manifest.json
$Manifest = Get-Content .\pack\manifest.json -Raw | ConvertFrom-Json
Write-Host "$(TimeCode) Found artifact name: $($Manifest.name)"
Write-Host "$(TimeCode) Found artifact version: $($Manifest.version)"
Remove-Item -Force .\build\artifact\*.zip
$ArtifactName = "$($Manifest.name)-v$($Manifest.version)".Replace(' ', '-')
7z u "$(Resolve-Path .\build\artifact\)$ArtifactName.zip" "$(Resolve-Path .\pack\)*" | Out-Null
Write-Host "$(TimeCode) Created artifact: $(Resolve-Path .\build\artifact\)$ArtifactName.zip"

Write-Host "$(TimeCode) Completed task: build"

Set-Location $PrevDir
