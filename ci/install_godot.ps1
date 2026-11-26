# Installe Godot 4.3 standard en mode autonome pour exporter le jeu (utilise par la CI, marche aussi en local) :
# l'editeur, les modeles d'export Windows et Web (sommes SHA512 officielles verifiees) et rcedit,
# qui pose l'icone sur l'exe. Ne fait rien si l'installation est deja complete (cache).
# Usage : .\ci\install_godot.ps1 -Destination <dossier> [-Project <dossier du projet>]

param(
    [Parameter(Mandatory = $true)][string]$Destination,
    [string]$Project = ""
)

$ErrorActionPreference = "Stop"
# Windows PowerShell 5.1 ne connait pas $PSScriptRoot dans les valeurs par defaut des parametres
if (-not $Project) { $Project = Split-Path $PSScriptRoot -Parent }
$ProgressPreference = "SilentlyContinue"

$version = "4.3-stable"
$releases = "https://github.com/godotengine/godot/releases/download/$version"
$editorZip = "Godot_v4.3-stable_win64.exe.zip"
$templatesTpz = "Godot_v4.3-stable_export_templates.tpz"
$rceditUrl = "https://github.com/electron/rcedit/releases/download/v2.0.0/rcedit-x64.exe"
$templateFiles = @(
    "version.txt",
    "windows_release_x86_64.exe",
    "windows_debug_x86_64.exe",
    "web_nothreads_release.zip",
    "web_nothreads_debug.zip"
)

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$Destination = (Resolve-Path $Destination).Path
$console = Join-Path $Destination "Godot_v4.3-stable_win64_console.exe"
$templatesDir = Join-Path $Destination "editor_data\export_templates\4.3.stable"
$rcedit = Join-Path $Destination "rcedit-x64.exe"
$settings = Join-Path $Destination "editor_data\editor_settings-4.3.tres"

function Test-Installed {
    if (-not (Test-Path $console) -or -not (Test-Path $rcedit) -or -not (Test-Path $settings)) { return $false }
    foreach ($file in $templateFiles) {
        if (-not (Test-Path (Join-Path $templatesDir $file))) { return $false }
    }
    return $true
}

if (Test-Installed) {
    Write-Host "Godot deja installe dans $Destination"
    exit 0
}

# Telecharge un fichier de la release et verifie sa somme SHA512 officielle
function Get-Verified([string]$name, [hashtable]$sums) {
    $target = Join-Path $Destination $name
    Invoke-WebRequest -Uri "$releases/$name" -OutFile $target -UseBasicParsing
    $actual = (Get-FileHash $target -Algorithm SHA512).Hash.ToLower()
    if ($actual -ne $sums[$name]) {
        Remove-Item $target -Force
        throw "Somme SHA512 fausse pour $name"
    }
    return $target
}

$sums = @{}
$sumsFile = Join-Path $Destination "SHA512-SUMS.txt"
Invoke-WebRequest -Uri "$releases/SHA512-SUMS.txt" -OutFile $sumsFile -UseBasicParsing
foreach ($line in Get-Content $sumsFile) {
    $parts = $line.Trim() -split "\s+"
    if ($parts.Count -eq 2) { $sums[$parts[1]] = $parts[0].ToLower() }
}
Remove-Item $sumsFile -Force

# Editeur, en mode autonome : ses reglages et modeles restent dans editor_data
$zip = Get-Verified $editorZip $sums
Expand-Archive -Path $zip -DestinationPath $Destination -Force
Remove-Item $zip -Force
New-Item -ItemType File -Force -Path (Join-Path $Destination "._sc_") | Out-Null

# Modeles d'export : seulement ceux de Windows et du Web sans threads
$tpz = Get-Verified $templatesTpz $sums
New-Item -ItemType Directory -Force -Path $templatesDir | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($tpz)
try {
    foreach ($file in $templateFiles) {
        $entry = $archive.GetEntry("templates/$file")
        if (-not $entry) { throw "Modele absent de l'archive : $file" }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $templatesDir $file), $true)
    }
} finally {
    $archive.Dispose()
}
Remove-Item $tpz -Force

Invoke-WebRequest -Uri $rceditUrl -OutFile $rcedit -UseBasicParsing

# Le premier lancement cree les reglages de l'editeur, ou l'on declare rcedit
& $console --headless --path $Project --import | Out-Null
if (-not (Test-Path $settings)) { throw "Reglages de l'editeur non crees : $settings" }
$rceditPath = $rcedit.Replace("\", "/")
$content = Get-Content $settings -Raw
$content = $content -replace 'export/windows/rcedit = ".*"', "export/windows/rcedit = `"$rceditPath`""
Set-Content -Path $settings -Value $content -NoNewline
if (-not (Select-String -Path $settings -SimpleMatch "export/windows/rcedit = `"$rceditPath`"" -Quiet)) {
    throw "Chemin de rcedit non ecrit dans $settings"
}

Write-Host "Godot installe dans $Destination"
exit 0
