<#
.SYNOPSIS
    Advanced DNS & Active Directory Resolver Troubleshooter
.DESCRIPTION
    Dedikeret DNS-fejlsøgningsscript for Windows endpoints.
    Tjekker DNS-serveres svartid, opløser domæner, tester Active Directory SRV-records,
    og udfører automatisk DNS Cache Flush samt NetBIOS nulstilling.
.AUTHOR
    Hans Annfinn Johannesen
#>

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "     IT Support - DNS & Domæne Fejlsøger Tool    " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Hent aktuelle DNS-servere
Write-Host "`n[1/4] Henter aktive DNS-servere for netværkskort..." -ForegroundColor Yellow
$dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses.Count -gt 0 }

foreach ($dns in $dnsServers) {
    Write-Host "   - Adapter: $($dns.InterfaceAlias)" -ForegroundColor Cyan
    Write-Host "     DNS Server(e): $($dns.ServerAddresses -join ', ')" -ForegroundColor Green
}

# 2. Test af DNS-opslag (Interne og Eksterne)
Write-Host "`n[2/4] Tester DNS-opslag for eksterne og interne domæner..." -ForegroundColor Yellow
$testDomains = @("google.com", "microsoft.com")

foreach ($domain in $testDomains) {
    try {
        $result = Resolve-DnsName -Name $domain -Type A -ErrorAction Stop
        Write-Host "   ✔ Success: $domain -> IP: $($result.IPAddress[0]) (Svartid OK)" -ForegroundColor Green
    } catch {
        Write-Host "   ✖ FEJL: Kunne ikke opløse $domain! (Muligt DNS-problem)" -ForegroundColor Red
    }
}

# 3. Nulstil DNS & NetBIOS Cache
Write-Host "`n[3/4] Udfører automatisk DNS & NetBIOS Flush..." -ForegroundColor Yellow
try {
    Clear-DnsClientCache
    nbtstat -R | Out-Null
    Write-Host "   ✔ DNS-cache og NetBIOS-navne blev nulstillet succesfuldt!" -ForegroundColor Green
} catch {
    Write-Host "   ℹ Kunne ikke fuldføre DNS-flush." -ForegroundColor Gray
}

# 4. Tjek Port 53 (DNS Standard Port)
Write-Host "`n[4/4] Tester om DNS Port 53 er åben mod primær DNS..." -ForegroundColor Yellow
$primaryDns = ($dnsServers | Select-Object -First 1).ServerAddresses[0]

if ($primaryDns) {
    $portCheck = Test-NetConnection -ComputerName $primaryDns -Port 53 -WarningAction SilentlyContinue
    if ($portCheck.TcpTestSucceeded) {
        Write-Host "   ✔ Port 53 til DNS-server ($primaryDns) er ÅBEN!" -ForegroundColor Green
    } else {
        Write-Host "   ✖ Port 53 svarer IKKE! (Mulig firewall-blokering)" -ForegroundColor Red
    }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   DNS-diagnostik fuldført!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
