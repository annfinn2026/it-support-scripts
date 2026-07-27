<#
.SYNOPSIS
    IT Support Printer Search & Troubleshooter Tool
.DESCRIPTION
    Hjælpescript til at søge efter installerede printere, netværksprintere og printservere,
    samt tjekke Print Spooler status og netværksport (Port 9100 / RAW).
.AUTHOR
    Hans Annfinn Johannesen
#>

param (
    [string]$SearchPattern = "*",
    [string]$PrintServer = ""
)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "    IT Support - Printer Søg & Diagnostik        " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Tjek Print Spooler Tjeneste
Write-Host "`n[1/3] Tjekker status for Print Spooler tjenesten..." -ForegroundColor Yellow
$spooler = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue

if ($spooler.Status -eq "Running") {
    Write-Host "   ✔ Print Spooler kører normalt." -ForegroundColor Green
} else {
    Write-Host "   ✖ Print Spooler kører IKKE! Status: $($spooler.Status)" -ForegroundColor Red
    Write-Host "   Genstarter Print Spooler..." -ForegroundColor Yellow
    Restart-Service -Name "Spooler" -Force
}

# 2. Søg efter installerede printere
Write-Host "`n[2/3] Søger efter printere (Søgeord: '$SearchPattern')..." -ForegroundColor Yellow

try {
    if ($PrintServer -ne "") {
        Write-Host "   Søger på printserver: $PrintServer" -ForegroundColor Cyan
        $printers = Get-Printer -ComputerName $PrintServer | Where-Object { $_.Name -like "*$SearchPattern*" -or $_.PortName -like "*$SearchPattern*" }
    } else {
        $printers = Get-Printer | Where-Object { $_.Name -like "*$SearchPattern*" -or $_.PortName -like "*$SearchPattern*" }
    }

    if ($printers) {
        foreach ($p in $printers) {
            $status = if ($p.PrinterStatus -eq "Normal") { "Grøn/Klar" } else { $p.PrinterStatus }
            Write-Host "   🖨  Navn:       $($p.Name)" -ForegroundColor Green
            Write-Host "      Port:       $($p.PortName)" -ForegroundColor Gray
            Write-Host "      Driver:     $($p.DriverName)" -ForegroundColor Gray
            Write-Host "      Status:     $status" -ForegroundColor Gray
            Write-Host "   ---------------------------------------------" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ℹ Ingen printere fundet der matchede søgningen." -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✖ Fejl ved hentning af printere: $_" -ForegroundColor Red
}

# 3. Test netværksforbindelse til netværksprinter (Port 9100 RAW)
if ($SearchPattern -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$") {
    Write-Host "`n[3/3] Søgeord ligner en IP-adresse. Tester netværksprint-port (9100 RAW)..." -ForegroundColor Yellow
    $portTest = Test-NetConnection -ComputerName $SearchPattern -Port 9100 -WarningAction SilentlyContinue
    if ($portTest.TcpTestSucceeded) {
        Write-Host "   ✔ Netværksprinter svarer på Port 9100 (RAW Print OK)!" -ForegroundColor Green
    } else {
        Write-Host "   ✖ Ingen svar på Port 9100. Tjek om printeren er tændt og på netværket." -ForegroundColor Red
    }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
