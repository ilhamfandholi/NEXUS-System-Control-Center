function Get-NexusDiskInfo {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        ForEach-Object {
            if ($_.Size -gt 0) {
                [PSCustomObject]@{
                    Drive = $_.DeviceID
                    Label = $_.VolumeName
                    TotalGB = [math]::Round($_.Size / 1GB, 2)
                    UsedGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
                    FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
                    UsedPercent = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1)
                }
            }
        }
}

function Get-NexusTopFolders {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z]:\\?$')]
        [string]$Drive
    )

    $root = "$($Drive.Substring(0,1)):\"

    if (!(Test-Path -LiteralPath $root -PathType Container)) {
        throw "Drive tidak ditemukan: $root"
    }

    $folders = Get-ChildItem -LiteralPath $root -Directory -Force -ErrorAction SilentlyContinue
    $results = foreach ($folder in $folders) {
        $size = (Get-ChildItem -LiteralPath $folder.FullName -File -Recurse -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum

        [PSCustomObject]@{
            Folder = $folder.Name
            Path = $folder.FullName
            SizeGB = [math]::Round(([double]$size / 1GB), 3)
        }
    }

    $results | Sort-Object SizeGB -Descending | Select-Object -First 10
}
