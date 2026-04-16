# ============================================
# Vaultify Keystore Setup Script
# ============================================
# This script generates the release keystore,
# encodes it to base64 for GitHub Secrets,
# and updates key.properties with your password.
#
# IMPORTANT: Backup your keystore securely!
# ============================================

param(
    [Parameter(Mandatory=$true)]
    [SecureString]$Password,
    
    [Parameter(Mandatory=$false)]
    [string]$KeystorePath = "android\app\release-keystore.jks",
    
    [Parameter(Mandatory=$false)]
    [string]$Alias = "vaultify"
)

$ErrorActionPreference = "Stop"

# Convert password to plain text for keytool
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Vaultify Release Keystore Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Find keytool
$keytool = $null
$javaCmd = Get-Command java -ErrorAction SilentlyContinue

if ($javaCmd) {
    $javaHome = Split-Path $javaCmd.Source | Split-Path
    $potentialKeytool = Join-Path $javaHome "bin\keytool.exe"
    if (Test-Path $potentialKeytool) {
        $keytool = $potentialKeytool
    }
}

if (-not $keytool) {
    # Try common paths
    $commonPaths = @(
        "C:\Program Files\Java\jdk*\bin\keytool.exe",
        "C:\Program Files (x86)\Java\jdk*\bin\keytool.exe",
        "${env:LOCALAPPDATA}\Android\jdk\bin\keytool.exe"
    )
    
    foreach ($path in $commonPaths) {
        $found = Get-ChildItem $path -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($found) {
            $keytool = $found.FullName
            break
        }
    }
}

if (-not $keytool) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    Write-Host "Please ensure Java JDK is installed and keytool is in your PATH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can download Java JDK from: https://adoptium.net/" -ForegroundColor Cyan
    exit 1
}

Write-Host "[OK] Found keytool: $keytool" -ForegroundColor Green

# Step 2: Generate Keystore
Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Yellow

$absoluteKeystorePath = if ([System.IO.Path]::IsPathRooted($KeystorePath)) {
    $KeystorePath
} else {
    Join-Path (Get-Location) $KeystorePath
}

# Remove existing keystore if present
if (Test-Path $absoluteKeystorePath) {
    Write-Host "Removing existing keystore..." -ForegroundColor Yellow
    Remove-Item $absoluteKeystorePath -Force
}

# Generate new keystore
$keytoolArgs = @(
    "-genkeypair",
    "-v",
    "-storetype", "JKS",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-keystore", $absoluteKeystorePath,
    "-alias", $Alias,
    "-storepass", $PlainPassword,
    "-keypass", $PlainPassword,
    "-dname", "CN=Vaultify, OU=Development, O=Vaultify, L=City, ST=State, C=US"
)

& $keytool $keytoolArgs 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to generate keystore!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Keystore generated: $absoluteKeystorePath" -ForegroundColor Green

# Step 3: Encode to Base64
Write-Host ""
Write-Host "Encoding keystore to base64..." -ForegroundColor Yellow

$base64Content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($absoluteKeystorePath))
$base64Path = Join-Path (Split-Path $absoluteKeystorePath -Parent) "keystore_base64.txt"
$base64Content | Out-File -FilePath $base64Path -Encoding ASCII

Write-Host "[OK] Base64 encoded: $base64Path" -ForegroundColor Green

# Step 4: Update key.properties
Write-Host ""
Write-Host "Updating key.properties..." -ForegroundColor Yellow

$keyPropsPath = Join-Path (Split-Path $absoluteKeystorePath -Parent) "key.properties"
@"
storePassword=$PlainPassword
keyPassword=$PlainPassword
keyAlias=$Alias
storeFile=release-keystore.jks
"@ | Out-File -FilePath $keyPropsPath -Encoding ASCII

Write-Host "[OK] key.properties updated: $keyPropsPath" -ForegroundColor Green

# Cleanup
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) | Out-Null

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy the base64 content from:" -ForegroundColor White
Write-Host "   $base64Path" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Add these GitHub Secrets:" -ForegroundColor White
Write-Host "   - KEYSTORE_FILE: (paste the base64 content)" -ForegroundColor Cyan
Write-Host "   - KEYSTORE_PASSWORD: $PlainPassword" -ForegroundColor Cyan
Write-Host "   - KEY_ALIAS: $Alias" -ForegroundColor Cyan
Write-Host "   - KEY_PASSWORD: $PlainPassword" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. IMPORTANT: Backup your keystore securely!" -ForegroundColor Red
Write-Host "   $absoluteKeystorePath" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Delete the base64 file after adding secrets:" -ForegroundColor White
Write-Host "   Remove-Item $base64Path" -ForegroundColor Cyan
Write-Host ""

# Show base64 content for easy copying
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host "Base64 content (first 100 chars):" -ForegroundColor Gray
Write-Host "$($base64Content.Substring(0, [Math]::Min(100, $base64Content.Length)))..." -ForegroundColor Gray
Write-Host "----------------------------------------" -ForegroundColor Gray
