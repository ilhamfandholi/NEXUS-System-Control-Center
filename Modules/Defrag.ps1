function Get-NexusDefragInfo {
    Get-Volume | Where-Object {
        $_.DriveLetter -and $_.DriveType -eq "Fixed"
    } | ForEach-Object {
        $drive = "$($_.DriveLetter):"

        $media = "Unknown"
        try {
            $partition = Get-Partition -DriveLetter $_.DriveLetter
            $disk = Get-Disk -Number $partition.DiskNumber
            $media = $disk.MediaType
        } catch {}

        [PSCustomObject]@{
            Drive = $drive
            FileSystem = $_.FileSystem
            MediaType = $media
            Health = $_.HealthStatus
            SizeGB = [math]::Round($_.Size / 1GB, 2)
            FreeGB = [math]::Round($_.SizeRemaining / 1GB, 2)
        }
    }
}

function Invoke-NexusDefragAnalysis {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]:$')]
        [string]$Drive
    )

    Optimize-Volume -DriveLetter $Drive.TrimEnd(':') -Analyze -Verbose
}

function Get-NexusDefragInfo {
    $physicalDisks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)

    Get-Volume | Where-Object {
        $_.DriveLetter -and $_.DriveType -eq "Fixed"
    } | ForEach-Object {
        $letter = $_.DriveLetter
        $media = "Unknown"

        try {
            $partition = Get-Partition -DriveLetter $letter
            $disk = Get-Disk -Number $partition.DiskNumber

            $physical = $physicalDisks |
                Where-Object { $_.DeviceId -eq [string]$disk.Number } |
                Select-Object -First 1

            if (-not $physical -and $physicalDisks.Count -eq 1) {
                $physical = $physicalDisks[0]
            }

            if ($physical) {
                $media = [string]$physical.MediaType
            }
        } catch {}

        [PSCustomObject]@{
            Drive = "$letter`:"
            FileSystem = $_.FileSystem
            MediaType = $media
            Health = $_.HealthStatus
            SizeGB = [math]::Round($_.Size / 1GB, 2)
            FreeGB = [math]::Round($_.SizeRemaining / 1GB, 2)
        }
    }
}

function Invoke-NexusDefragAnalysis {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]:$')]
        [string]$Drive
    )

    $letter = $Drive.Substring(0,1)
    Optimize-Volume -DriveLetter $letter -Analyze -Verbose 4>&1 |
        Out-String
}

function Invoke-NexusDefragOptimize {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]:$')]
        [string]$Drive
    )

    $info = Get-NexusDefragInfo |
        Where-Object { $_.Drive -eq $Drive } |
        Select-Object -First 1

    if (-not $info) {
        throw "Drive tidak ditemukan."
    }

    if ($info.MediaType -eq "HDD") {
        $result = Optimize-Volume -DriveLetter $Drive.Substring(0,1) -Defrag -Verbose 4>&1 |
            Out-String
    }
    elseif ($info.MediaType -eq "SSD") {
        $result = Optimize-Volume -DriveLetter $Drive.Substring(0,1) -ReTrim -Verbose 4>&1 |
            Out-String
    }
    else {
        throw "Jenis drive tidak diketahui. Optimasi dibatalkan demi keamanan."
    }

    return $result
}
