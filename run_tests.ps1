# Lance tous les tests GUT en headless. Code de sortie : 0 = succes, autre = echec.
# Usage : .\run_tests.ps1
# Pour utiliser un autre Godot : definir la variable d'environnement GODOT_BIN.

$godot = $env:GODOT_BIN
if (-not $godot) {
    $godot = "F:\informatique\Godot_v4.3-stable_mono_win64\Godot_v4.3-stable_mono_win64_console.exe"
}

if (-not (Test-Path $godot)) {
    Write-Error "Godot introuvable : $godot. Definis GODOT_BIN avec le chemin de l'executable console."
    exit 2
}

# Enregistre les class_name (dont GutTest) : necessaire apres un clone ou un nouvel addon.
& $godot --headless --path $PSScriptRoot --import | Out-Null

& $godot --headless --path $PSScriptRoot -s "res://addons/gut/gut_cmdln.gd"
exit $LASTEXITCODE
