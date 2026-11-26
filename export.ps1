# Exporte le jeu pour Windows (un seul exe) et pour le Web, puis cree un zip par plateforme
# dans builds/. Code de sortie : 0 = succes, autre = echec.
# Usage : .\export.ps1
# L'export utilise Godot 4.3 standard (pas .NET) en mode autonome : ses modeles d'export et rcedit
# sont dans son dossier editor_data. Pour un autre Godot : definir GODOT_EXPORT_BIN.

$godot = $env:GODOT_EXPORT_BIN
if (-not $godot) {
    $godot = "F:\informatique\Godot_v4.3-stable_win64\Godot_v4.3-stable_win64_console.exe"
}

if (-not (Test-Path $godot)) {
    Write-Error "Godot introuvable : $godot. Definis GODOT_EXPORT_BIN avec le chemin de l'executable console."
    exit 2
}

$root = $PSScriptRoot
$builds = Join-Path $root "builds"
$targets = @(
    @{ Preset = "Windows Desktop"; Dir = "windows"; File = "BossHide.exe"; Zip = "BossHide-windows.zip" },
    @{ Preset = "Web"; Dir = "web"; File = "index.html"; Zip = "BossHide-web.zip" }
)
$licenses = Get-ChildItem (Join-Path $root "assets\fonts") -Filter "*.txt"

# builds/ est dans le projet : sans .gdignore, Godot importerait les images des builds web
New-Item -ItemType Directory -Force -Path $builds | Out-Null
New-Item -ItemType File -Force -Path (Join-Path $builds ".gdignore") | Out-Null

& $godot --headless --path $root --import | Out-Null

foreach ($target in $targets) {
    $dir = Join-Path $builds $target.Dir
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
    New-Item -ItemType Directory -Path $dir | Out-Null

    & $godot --headless --path $root --export-release $target.Preset (Join-Path $dir $target.File)
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $dir $target.File))) {
        Write-Error "Export $($target.Preset) rate"
        exit 1
    }

    # Les licences des polices doivent accompagner le jeu
    $licenseDir = New-Item -ItemType Directory -Path (Join-Path $dir "licenses")
    $licenses | Copy-Item -Destination $licenseDir

    $zip = Join-Path $builds $target.Zip
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path (Join-Path $dir "*") -DestinationPath $zip
    Write-Host "OK : $zip"
}
exit 0
