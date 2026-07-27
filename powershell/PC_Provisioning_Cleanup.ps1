<#
.SYNOPSIS
    Enterprise PC Provisioning & System Cleanup Tool
.DESCRIPTION
    Automatiseret klargørings- og oprydningsscript for Windows endpoints.
    Renser temporære filer, tjekker Intune/Windows Update tjenester og automatiserer
    installation af standardsoftware via Microsoft Winget.
.AUTHOR
    Hans Annfinn Johannesen
#>

# Tjek om scriptet køres med Administrator-rettigheder
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠ Dette script kræver Administrator-rettigheder. Genstart venligst PowerShell som Administrator." -ForegroundColor Red
    exit
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  IT Support - PC Klargøring & Oprydning Tool    " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. System Oprydning (Temp filer & Cache)
Write-Host "`n[1/3] Renser temporære filer og system-cache..." -ForegroundColor Yellow

$tempFolders = @(
    "C:\Windows\Temp\*",
    "$env:LOCALAPPDATA\Temp\*"
)

foreach ($folder in $tempFolders) {
    try {
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✔ Oprydning udført for: $folder" -ForegroundColor Green
    } catch {
        Write-Host "   ℹ Nogle filer var i brug og blev sprunget over." -ForegroundColor Gray
    }
}

# 2. Tjek Windows Update & Intune Tjenester
Write-Host "`n[2/3] Tjekker systemtjenester (Windows Update & BITS)..." -ForegroundColor Yellow
$services = @("wuauserv", "BITS")

foreach ($svcName in $services) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc.Status -ne "Running") {
        Write-Host "   Startes: $svcName..." -ForegroundColor Yellow
        Start-Service -Name $svcName -ErrorAction SilentlyContinue
    }
    Write-Host "   ✔ Tjeneste status for $svcName: $($svc.Status)" -ForegroundColor Green
}

# 3. Klargøring & Installation af Standard Software via Winget
Write-Host "`n[3/3] Klargøring af standard software via Winget..." -ForegroundColor Yellow

if (Get-Command winget -ErrorAction SilentlyContinue) {
    $packages = @(
        @{ Name = "7-Zip"; Id = "7zip.7zip" },
        @{ Name = "Google Chrome"; Id = "Google.Chrome" },
        @{ Name = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit" }
    )

    foreach ($pkg in $packages) {
        Write-Host "   Tjekker/installerer: $($pkg.Name)..." -ForegroundColor Cyan
        winget install --id $($pkg.Id) --exact --accept-package-agreements --accept-source-agreements --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✔ $($pkg.Name) er klar/opdateret!" -ForegroundColor Green
        } else {
            Write-Host "   ℹ $($pkg.Name) var allerede installeret eller sprunget over." -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   ℹ Winget er ikke tilgængelig på denne maskine." -ForegroundColor Yellow
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   PC Klargøring fuldført med succes!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
