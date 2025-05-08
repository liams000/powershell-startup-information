function Show-FastSystemInfo {
    [CmdletBinding()]
    param()

    $progressPreference = 'SilentlyContinue'  # Suppress progress bars for faster execution
    
    # Colors
    $titleColor = "Cyan"
    $infoColor = "White"
    $accentColor = "Green"
    $warningColor = "Yellow"
    
    # Get basic system info (fast operations only)
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -Property Model,Manufacturer,TotalPhysicalMemory -ErrorAction SilentlyContinue
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption,Version,LastBootUpTime -ErrorAction SilentlyContinue
    $bios = Get-CimInstance -ClassName Win32_BIOS -Property SerialNumber -ErrorAction SilentlyContinue
    $processor = Get-CimInstance -ClassName Win32_Processor -Property Name,NumberOfCores,NumberOfLogicalProcessors -ErrorAction SilentlyContinue
    
    # Calculate memory
    $ramTotal = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
    $ramUsed = [math]::Round(($computerSystem.TotalPhysicalMemory - $os.FreePhysicalMemory * 1MB) / 1GB, 2)
    $ramPercentage = [math]::Round(($ramUsed / $ramTotal) * 100, 0)
    
    # Calculate uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    $uptimeString = "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
    
    # Get system drive info (usually C:)
    $systemDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -Property Size,FreeSpace -ErrorAction SilentlyContinue
    $driveTotal = [math]::Round($systemDrive.Size / 1GB, 2)
    $driveFree = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
    $drivePercentage = [math]::Round(($driveFree / $driveTotal) * 100, 0)
    
    # Draw logo
    Write-Host ""
    $logo = @"
    ╭─────────────────────────╮
    │                         │
    │  ██████╗ ███████╗       │
    │  ██╔══██╗██╔════╝       │
    │  ██████╔╝███████╗       │
    │  ██╔═══╝ ╚════██║       │
    │  ██║     ███████║       │
    │  ╚═╝     ╚══════╝       │
    │                         │
    ╰─────────────────────────╯
"@
    
    foreach ($line in $logo -split "`n") {
        Write-Host $line -ForegroundColor $accentColor
    }
    
    # Draw horizontal line
    Write-Host ("─" * 60) -ForegroundColor $accentColor
    
    # System info
    Write-Host "  $($env:USERNAME)@$($env:COMPUTERNAME)" -ForegroundColor $titleColor
    Write-Host ("─" * 60) -ForegroundColor $accentColor
    
    # OS info
    Write-Host "  OS        : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$($os.Caption)" -ForegroundColor $infoColor
    
    # Hardware info
    Write-Host "  Model     : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$($computerSystem.Manufacturer) $($computerSystem.Model)" -ForegroundColor $infoColor
    
    # CPU info
    Write-Host "  CPU       : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$($processor.Name)" -ForegroundColor $infoColor
    Write-Host "  Cores     : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$($processor.NumberOfCores) physical, $($processor.NumberOfLogicalProcessors) logical" -ForegroundColor $infoColor
    
    # Memory
    Write-Host "  Memory    : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$ramUsed GB / $ramTotal GB ($ramPercentage%)" -ForegroundColor $infoColor
    
    # Disk
    Write-Host "  Disk (C:) : " -NoNewline -ForegroundColor $titleColor
    Write-Host "$driveFree GB free of $driveTotal GB ($drivePercentage% free)" -ForegroundColor $(if ($drivePercentage -lt 10) { $warningColor } else { $infoColor })
    
    # PowerShell info
    Write-Host "  PowerShell: " -NoNewline -ForegroundColor $titleColor
    Write-Host "$($PSVersionTable.PSVersion)" -ForegroundColor $infoColor
    
    # Terminal info
    Write-Host "  Terminal  : " -NoNewline -ForegroundColor $titleColor
    if ($env:WT_SESSION) {
        Write-Host "Windows Terminal" -ForegroundColor $infoColor
    } elseif ($host.Name -eq 'ConsoleHost') {
        Write-Host "PowerShell Console" -ForegroundColor $infoColor
    } else {
        Write-Host $host.Name -ForegroundColor $infoColor
    }
    
    # Uptime
    Write-Host "  Uptime    : " -NoNewline -ForegroundColor $titleColor
    Write-Host $uptimeString -ForegroundColor $infoColor
    
    # Draw horizontal line
    Write-Host ("─" * 60) -ForegroundColor $accentColor
    Write-Host ""
    
    $progressPreference = 'Continue'  # Restore progress preference
}

# To make it run at startup, just add this line at the end of your profile:
# Show-FastSystemInfo
