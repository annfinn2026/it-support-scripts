<#
.SYNOPSIS
    User Account & Access Helper
.DESCRIPTION
    Tjekker brugerkontostatus, AD/Entra grupper og genererer en hurtig statusrapport.
.AUTHOR
    Hans Annfinn Johannesen
#>

param (
    [string]$Username = $env:USERNAME
)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   IT Support - Bruger- & Rettighedsrapport      " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

Write-Host "Tjekker status for bruger: $Username" -ForegroundColor Yellow

# Tjek om brugeren er administrator på lokal maskine
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "   ✔ Rettigheder: Administrator" -ForegroundColor Green
} else {
    Write-Host "   ℹ Rettigheder: Standard Bruger" -ForegroundColor Blue
}

Write-Host "`nAktuelle miljøvariabler:" -ForegroundColor Yellow
Write-Host "   - Domæne/Computer: $env:USERDOMAIN" -ForegroundColor ShortCut
Write-Host "   - Logon Server:   $env:LOGONSERVER" -ForegroundColor ShortCut

Write-Host "`n=================================================" -ForegroundColor Cyan
