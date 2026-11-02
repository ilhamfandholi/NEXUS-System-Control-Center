function Get-NexusProcessList {
    Get-Process -ErrorAction SilentlyContinue |
        ForEach-Object {
            [PSCustomObject]@{
                PID = $_.Id
                Process = $_.ProcessName
                RAM_MB = [math]::Round($_.WorkingSet64 / 1MB, 1)
                CPU_Seconds = if ($null -ne $_.CPU) {
                    [math]::Round($_.CPU, 2)
                } else { 0 }
                Threads = $_.Threads.Count
                Handles = $_.HandleCount
            }
        } |
        Sort-Object RAM_MB -Descending
}

function Stop-NexusProcess {
    param(
        [Parameter(Mandatory)]
        [int]$ProcessId
    )

    $protected = @(0, 4, $PID)

    if ($ProcessId -in $protected) {
        throw "Proses sistem atau PowerShell dilindungi."
    }

    $process = Get-Process -Id $ProcessId -ErrorAction Stop

    if ($process.ProcessName -in @(
        "System", "Registry", "Idle", "csrss",
        "wininit", "services", "lsass", "smss"
    )) {
        throw "Proses inti Windows dilindungi."
    }

    $name = $process.ProcessName

    Stop-Process -Id $ProcessId -ErrorAction Stop

    [PSCustomObject]@{
        PID = $ProcessId
        Process = $name
        Result = "Process terminated"
    }
}
