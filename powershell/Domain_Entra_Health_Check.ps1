<#
.SYNOPSIS
    Active Directory & Entra ID Hybrid Registration Status Check
.DESCRIPTION
    Tjekker om klient-PC'en er korrelet joinet til Active Directory / Entra ID (Azure AD),
    og validerer Single Sign-On (SSO) og PRT-token status.
.AUTHOR
    Hans Annfinn Johannesen
#>

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  IT Support - Domæne & Entra ID Status Tool     " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Kør dsregcmd til tjek af Entra ID / Azure AD Join status
Write-Host "`n[1/2] Henter Hybrid Entra ID / Azure AD Join Status..." -ForegroundColor Yellow

if (Get-Command dsregcmd -ErrorAction SilentlyContinue) {
    $dsreg = dsregcmd /status | Out-String
    
    if ($dsreg -match "AzureAdJoined : YES") {
        Write-Host "   ✔ Azure AD / Entra ID Joined: JA" -ForegroundColor Green
    } else {
        Write-Host "   ℹ Azure AD / Entra ID Joined: NEJ / Ikke Registreret" -ForegroundColor Yellow
    }

    if ($dsreg -match "DomainJoined : YES") {
        Write-Host "   ✔ Lokal Active Directory Joined: JA" -ForegroundColor Green
    } else {
        Write-Host "   ℹ Lokal Active Directory Joined: NEJ" -ForegroundColor Yellow
    }

    if ($dsreg -match "PRT : YES") {
        Write-Host "   ✔ Primary Refresh Token (PRT): OK (SSO virker)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Primary Refresh Token (PRT): MANGLER (Måske SSO-problem)" -ForegroundColor Red
    }
} else {
    Write-Host "   ℹ dsregcmd er ikke tilgængeligt på dette operativsystem." -ForegroundColor Gray
}

Write-Host "`n=================================================" -ForegroundColor Cyan
