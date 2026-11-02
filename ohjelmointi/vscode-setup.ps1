# vscode-setup.ps1
# VS Code opiskelukayttoon: pikaasennus Windowsille.
#
# Ajo (PowerShell):
#   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\vscode-setup.ps1"
#
# Mita skripti tekee:
#   1. Asentaa winget-komennolla VS Coden, Pythonin ja Gitin (jos puuttuvat)
#   2. Asentaa laajennukset: Python, Pylance, Ruff, Error Lens (+ valinnaisesti oikoluku)
#   3. Kirjoittaa VS Coden kayttajaasetukset (vanhat varmuuskopioidaan ensin)
#   4. Kysyy, sallitaanko PowerShell-skriptit (tarvitaan .venv-ymparistojen aktivointiin)
#
# Skripti ei muuta mitaan muuta. Se on tavallista tekstia: voit lukea sen ennen ajoa.

$ErrorActionPreference = 'Stop'

function Ask($question) {
    $answer = Read-Host "$question (K/e)"
    return ($answer -eq '' -or $answer -match '^[KkYy]')
}

function Install-App($id, $name) {
    Write-Host ""
    Write-Host "== $name =="
    winget install --id $id -e --accept-package-agreements --accept-source-agreements
    Write-Host "(Jos winget sanoi, etta ohjelma on jo asennettu, se on ok.)"
}

function Find-Code {
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $paths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

Write-Host "=== VS Code opiskelukayttoon: pikaasennus ==="

# ---- 1. Ohjelmat ----
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "VIRHE: winget puuttyy. Paivita 'App Installer' Microsoft Storesta"
    Write-Host "tai asenna ohjelmat kasin oppaan kohdan 1 mukaan. Sitten aja skripti uudelleen."
    exit 1
}

Install-App 'Microsoft.VisualStudioCode' 'Visual Studio Code'
Install-App 'Python.Python.3.13' 'Python 3.13'
Install-App 'Git.Git' 'Git'

# ---- 2. Laajennukset ----
$code = Find-Code
if (-not $code) {
    Write-Host ""
    Write-Host "VIRHE: code-komentoa ei loytynyt. Sulje PowerShell, avaa uusi ja aja skripti uudelleen."
    exit 1
}

$extensions = @(
    'ms-python.python',
    'ms-python.vscode-pylance',
    'charliermarsh.ruff',
    'usernamehw.errorlens'
)
if (Ask "Asennetaanko myos suomen oikoluku (Code Spell Checker + Finnish)") {
    $extensions += 'streetsidesoftware.code-spell-checker'
    $extensions += 'streetsidesoftware.code-spell-checker-finnish'
}

Write-Host ""
Write-Host "== Laajennukset =="
foreach ($ext in $extensions) {
    Write-Host "Asennetaan $ext ..."
    & $code --install-extension $ext --force
}

# ---- 3. Asetukset ----
$settingsJson = @'
{
  "files.autoSave": "afterDelay",
  "files.eol": "\n",
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "workbench.startupEditor": "none",
  "telemetry.telemetryLevel": "off",
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  }
}
'@

$settingsDir = Join-Path $env:APPDATA 'Code\User'
$settingsPath = Join-Path $settingsDir 'settings.json'
New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

Write-Host ""
Write-Host "== Asetukset =="
$writeSettings = $true
if (Test-Path $settingsPath) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = "$settingsPath.bak-$stamp"
    Copy-Item $settingsPath $backup
    Write-Host "Vanhat asetukset varmuuskopioitu: $backup"
    $writeSettings = Ask "Korvataanko nykyiset asetukset uusilla"
}
if ($writeSettings) {
    [System.IO.File]::WriteAllText($settingsPath, $settingsJson, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Asetukset kirjoitettu: $settingsPath"
} else {
    Write-Host "Asetuksia ei muutettu."
}

# ---- 4. PowerShell-skriptit (.venv-aktivointi) ----
Write-Host ""
Write-Host "== PowerShell-skriptit =="
Write-Host "Ilman tata PowerShell voi estaa .venv-ymparistojen aktivoinnin"
Write-Host "(virhe: running scripts is disabled). Asetus koskee vain sinun kayttajaasi."
if (Ask "Sallitaanko skriptit (RemoteSigned, vain nykyiselle kayttajalle)") {
    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Host "Valmis."
    } catch {
        Write-Host "Asetusta ei voitu muuttaa (organisaation kayttopolitiikka?). Kayta tarvittaessa Command Prompt -terminaalia."
    }
}

# ---- Valmis ----
Write-Host ""
Write-Host "=== VALMIS ==="
Write-Host "Kaksi asiaa tehdaan viela kasin:"
Write-Host "  1. Asetukset > Sovellukset > Lisaasetukset > Sovellusten suoritusaliakset:"
Write-Host "     laita pois paalta python.exe ja python3.exe (oppaan kohta 2)."
Write-Host "  2. Sulje tama ikkuna ja kaynnista VS Code. Jatka oppaan kohdasta 3."
