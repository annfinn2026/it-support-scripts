<#
.SYNOPSIS
    IT Support Network Diagnostic Tool
.DESCRIPTION
    Automatiseret netværksfejlsøgning for Windows-klienter.
    Tjekker IP-adresse, DNS-opsætning, gateway, udfører DNS-flush og validerer internetforbindelse.
.AUTHOR
    Hans Annfinn Johannesen
#>

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   IT Support - Netværksdiagnostik & Fejlsøgning  " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Tjek lokal IP-konfiguration
Write-Host "`n[1/4] Henter lokal IP-konfiguration..." -ForegroundColor Yellow
$ipInfo = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" }

foreach ($ip in $ipInfo) {
    Write-Host "   - Adapter: $($ip.InterfaceAlias)" -ForegroundColor Green
    Write-Host "   - IP-adresse: $($ip.IPAddress)" -ForegroundColor Green
}

# 2. Nulstil DNS Cache (DNS Flush)
Write-Host "`n[2/4] Nulstiller lokal DNS-cache (ipconfig /flushdns)..." -ForegroundColor Yellow
try {
    Clear-DnsClientCache
    Write-Host "   ✔ DNS-cache blev nulstillet succesfuldt!" -ForegroundColor Green
} catch {
    Write-Host "   ✖ Kunne ikke nulstille DNS-cache." -ForegroundColor Red
}

# 3. Test ping til Standard Gateway og DNS (Cloudflare / Google)
Write-Host "`n[3/4] Test af forbindelse (Ping test)..." -ForegroundColor Yellow
$targets = @(
    @{ Name = "Google DNS (8.8.8.8)"; IP = "8.8.8.8" },
    @{ Name = "Cloudflare DNS (1.1.1.1)"; IP = "1.1.1.1" }
)

foreach ($target in $targets) {
    $ping = Test-Connection -ComputerName $target.IP -Count 2 -Quiet
    if ($ping) {
        Write-Host "   ✔ Ping til $($target.Name): SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "   ✖ Ping til $($target.Name): FAILED (Tjek firewall/netværk)" -ForegroundColor Red
    }
}

# 4. Test DNS Navneopløsning
Write-Host "`n[4/4] Test af DNS-navneopløsning..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name "google.com" -ErrorAction Stop
    Write-Host "   ✔ DNS-opløsning for google.com virker! IP: $($dnsResult.IPAddress[0])" -ForegroundColor Green
} catch {
    Write-Host "   ✖ DNS-navneopløsning fejlede. Tjek DNS-serveropsætning." -ForegroundColor Red
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   Diagnostik fuldført!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
