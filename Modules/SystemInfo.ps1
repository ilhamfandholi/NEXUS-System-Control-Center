function Get-NexusSystemInfo {
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $board = Get-CimInstance Win32_BaseBoard | Select-Object -First 1
    $os = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $gpu = @(Get-CimInstance Win32_VideoController)
    $ram = @(Get-CimInstance Win32_PhysicalMemory)
    $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)

    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $usedRAM = [math]::Round(
        ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 2
    )

    $uptime = (Get-Date) - $os.LastBootUpTime

    $memoryTypes = @{
        20 = "DDR"
        21 = "DDR2"
        24 = "DDR3"
        26 = "DDR4"
        34 = "DDR5"
    }

    $ramDetails = foreach ($stick in $ram) {
        $type = $memoryTypes[[int]$stick.SMBIOSMemoryType]
        if (-not $type) { $type = "Unknown" }

        "$([math]::Round($stick.Capacity / 1GB, 2)) GB $type @ $($stick.Speed) MHz"
    }

    $gpuDetails = foreach ($card in $gpu) {
        "$($card.Name) | Driver: $($card.DriverVersion)"
    }

    $diskDetails = foreach ($disk in $disks) {
        "$($disk.FriendlyName) | $($disk.MediaType) | $([math]::Round($disk.Size / 1GB, 1)) GB | $($disk.HealthStatus)"
    }

    [PSCustomObject]@{
        CPU = $cpu.Name.Trim()
        CPU_Cores = $cpu.NumberOfCores
        CPU_Threads = $cpu.NumberOfLogicalProcessors
        CPU_Current_MHz = $cpu.CurrentClockSpeed
        CPU_Max_MHz = $cpu.MaxClockSpeed

        Motherboard = "$($board.Manufacturer) $($board.Product)"
        BIOS = "$($bios.Manufacturer) $($bios.SMBIOSBIOSVersion)"

        RAM_Total_GB = $totalRAM
        RAM_Used_GB = $usedRAM
        RAM_Modules = $ram.Count
        RAM_Details = $ramDetails -join "; "

        GPU_Details = $gpuDetails -join "`n"

        Windows = $os.Caption
        Windows_Version = $os.Version
        Build = $os.BuildNumber
        Architecture = $os.OSArchitecture
        Uptime = "$([int]$uptime.TotalDays) hari $($uptime.Hours) jam"

        Physical_Disks = $disks.Count
        Disk_Details = $diskDetails -join "`n"
    }
}
