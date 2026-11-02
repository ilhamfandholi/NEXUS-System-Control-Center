function Get-RAMInfo {
    $os = Get-CimInstance Win32_OperatingSystem

    $total = [double]$os.TotalVisibleMemorySize
    $free = [double]$os.FreePhysicalMemory
    $used = $total - $free

    [PSCustomObject]@{
        TotalGB = [math]::Round($total / 1MB, 2)
        UsedGB  = [math]::Round($used / 1MB, 2)
        FreeGB  = [math]::Round($free / 1MB, 2)
        Percent = [math]::Round(($used / $total) * 100, 1)
    }
}

function Get-TopRAMProcesses {
    Get-Process |
        Sort-Object WorkingSet64 -Descending |
        Select-Object -First 10 Id, ProcessName,
        @{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet64 / 1MB, 1)}}
}

function Optimize-SelectedProcess {
    param([int]$ProcessId)

    if ($ProcessId -in @(0, 4, $PID)) {
        throw "Proses sistem atau PowerShell tidak boleh dioptimasi."
    }

    $process = Get-Process -Id $ProcessId -ErrorAction Stop

    if ($process.ProcessName -in @("System", "Registry", "Idle")) {
        throw "Proses sistem dilindungi."
    }

    $before = $process.WorkingSet64

    $process.MinWorkingSet = $process.MinWorkingSet
    $process.MaxWorkingSet = $process.MaxWorkingSet

    [PSCustomObject]@{
        Process = $process.ProcessName
        BeforeMB = [math]::Round($before / 1MB, 2)
        Message = "Working set tidak dipaksa dikosongkan."
    }
}
