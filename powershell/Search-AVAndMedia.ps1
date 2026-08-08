<#
.SYNOPSIS
    AV Hardware, Software og Mediefil Søge-Script
.DESCRIPTION
    Udviklet til AV-support, TV-studieproduktion og IT-administration.
    Scanner systemet for tilsluttede lydkort, mikrofoner, kameraer, aktive AV-processer
    samt foretager søgning og audit af mediefiler på disken.
.EXAMPLE
    .\Search-AVAndMedia.ps1 -PathToScan "C:\Users"
#>

param(
    [string]$PathToScan = "$env:USERPROFILE",
    [string]$ExportCsvPath = "$env:USERPROFILE\Desktop\AV_Media_Rapport.csv"
)

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   AV & MEDIA DIAGNOSTIK OG SØGE-SCRIPT          " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. SØG EFTER TILSLUTTEDE AV-ENHEDER (Lydkort, Kameraer, Capture Cards)
Write-Host "`n[1/3] Søger efter tilsluttede AV-hardwareenheder..." -ForegroundColor Yellow

$audioDevices = Get-CimInstance Win32_SoundDevice | Select-Object Name, Status, Manufacturer
$videoDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.PNPClass -eq "Camera" -or $_.PNPClass -eq "Image" } | Select-Object Name, Status, DeviceID

Write-Host "`n--- 🎧 Lydkort & Audio Interfaces ---" -ForegroundColor Green
if ($audioDevices) {
    $audioDevices | Format-Table -AutoSize
} else {
    Write-Host "Ingen audio-enheder fundet." -ForegroundColor Red
}

Write-Host "--- 📹 Kameraer & Video Enheder ---" -ForegroundColor Green
if ($videoDevices) {
    $videoDevices | Format-Table -AutoSize
} else {
    Write-Host "Ingen video-enheder fundet." -ForegroundColor Red
}

# 2. SØG EFTER AKTIVE AV-PROGRAMMER
Write-Host "`n[2/3] Tjekker aktive AV- og streaming-processer..." -ForegroundColor Yellow
$avProcessNames = "obs|teams|zoom|vmix|audacity|ffmpeg|premiere|handbrake|camtasia|vlc"
$activeAV = Get-Process | Where-Object { $_.Name -match $avProcessNames }

if ($activeAV) {
    Write-Host "--- 🟢 Aktive AV-Programmer Kører ---" -ForegroundColor Green
    $activeAV | Select-Object ProcessName, Id, @{Name="Hukommelse (MB)"; Expression={[math]::Round($_.WorkingSet64 / 1MB, 1)}} | Format-Table -AutoSize
} else {
    Write-Host "Ingen aktive AV/streaming-processer kører lige nu." -ForegroundColor Gray
}

# 3. SØG EFTER MEDIEFILER PÅ DISKEN
Write-Host "`n[3/3] Søger efter mediefiler i: $PathToScan ..." -ForegroundColor Yellow
$mediaExtensions = @("*.mp4", "*.mov", "*.mkv", "*.avi", "*.wav", "*.mp3", "*.flac", "*.aac", "*.m4a", "*.prproj", "*.drp")

$mediaFiles = Get-ChildItem -Path $PathToScan -Include $mediaExtensions -Recurse -ErrorAction SilentlyContinue | 
    Select-Object Name, 
                  @{Name="Størrelse (MB)"; Expression={[math]::Round($_.Length / 1MB, 2)}}, 
                  Extension, 
                  LastWriteTime, 
                  DirectoryName

if ($mediaFiles) {
    Write-Host ("✅ Fundet {0} mediefiler." -f $mediaFiles.Count) -ForegroundColor Green
    
    # Eksporter til CSV
    $mediaFiles | Export-Csv -Path $ExportCsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "📄 Rapport eksporteret til: $ExportCsvPath" -ForegroundColor Cyan
} else {
    Write-Host "Ingen mediefiler fundet i den angivne sti." -ForegroundColor Red
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "   SCANNING AFSLUTTET                            " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
