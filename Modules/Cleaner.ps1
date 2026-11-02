function Get-NexusScan {
    $targets = @(
        @{Name="User Temp"; Path=$env:TEMP}
        @{Name="Windows Temp"; Path="$env:windir\Temp"}
        @{Name="DirectX Shader Cache"; Path="$env:LOCALAPPDATA\D3DSCache"}
        @{Name="Thumbnail Cache"; Path="$env:LOCALAPPDATA\Microsoft\Windows\Explorer"}
        @{Name="Windows Error Reports"; Path="$env:LOCALAPPDATA\Microsoft\Windows\WER"}
        @{Name="Delivery Optimization"; Path="$env:windir\SoftwareDistribution\Download"}
    )

    $results = @()

    foreach ($target in $targets) {
        if (!(Test-Path -LiteralPath $target.Path)) { continue }

        $files = Get-ChildItem -LiteralPath $target.Path `
            -File -Recurse -Force -ErrorAction SilentlyContinue

        $allSize = ($files | Measure-Object Length -Sum).Sum
        $oldFiles = @($files | Where-Object {
            $_.Length -gt 0 -and
            $_.LastWriteTime -lt (Get-Date).AddHours(-24)
        })

        $oldSize = ($oldFiles | Measure-Object Length -Sum).Sum

        $results += [PSCustomObject]@{
            Category = $target.Name
            FileCount = @($files).Count
            TotalMB = [math]::Round($allSize / 1MB, 2)
            OldFiles = $oldFiles.Count
            PotentialMB = [math]::Round($oldSize / 1MB, 2)
            Path = $target.Path
        }
    }

    return $results
}
function Clear-NexusCache {
    $targets = @(
        @{
            Name = "DirectX Shader Cache"
            Path = "$env:LOCALAPPDATA\D3DSCache"
        },
        @{
            Name = "Thumbnail Cache"
            Path = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
        }
    )

    $deleted = 0
    $failed = 0
    $saved = [long]0

    foreach ($target in $targets) {
        if (!(Test-Path -LiteralPath $target.Path)) { continue }

        $files = Get-ChildItem -LiteralPath $target.Path `
            -File -Recurse -Force -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            if ($file.LastWriteTime -ge (Get-Date).AddHours(-24)) {
                continue
            }

            if ($target.Name -eq "Thumbnail Cache" -and
                $file.Name -notlike "thumbcache*") {
                continue
            }

            try {
                $size = [long]$file.Length
                Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                $deleted++
                $saved += $size
            }
            catch {
                $failed++
            }
        }
    }

    [PSCustomObject]@{
        DeletedFiles = $deleted
        FailedFiles = $failed
        SavedMB = [math]::Round($saved / 1MB, 2)
    }
}
function Clear-NexusCacheSelected {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Categories
    )

    $allowed = @("DirectX Shader Cache", "Thumbnail Cache")

    foreach ($category in $Categories) {
        if ($category -notin $allowed) {
            throw "Kategori tidak diizinkan: $category"
        }
    }

    $targets = @(
        @{Name="DirectX Shader Cache"; Path="$env:LOCALAPPDATA\D3DSCache"}
        @{Name="Thumbnail Cache"; Path="$env:LOCALAPPDATA\Microsoft\Windows\Explorer"}
    )

    $cutoff = (Get-Date).AddHours(-24)
    $deleted = 0
    $failed = 0
    [long]$saved = 0

    foreach ($target in $targets) {
        if ($target.Name -notin $Categories) { continue }
        if (!(Test-Path -LiteralPath $target.Path -PathType Container)) { continue }

        $root = [System.IO.Path]::GetFullPath($target.Path).TrimEnd('\') + '\'

        $files = Get-ChildItem -LiteralPath $target.Path -File -Recurse -Force -ErrorAction SilentlyContinue

        foreach ($file in $files) {
            try {
                $fullPath = [System.IO.Path]::GetFullPath($file.FullName)

                if (!$fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
                    continue
                }

                if ($file.LastWriteTime -ge $cutoff) { continue }

                if ($target.Name -eq "Thumbnail Cache" -and $file.Name -notlike "thumbcache*") {
                    continue
                }

                $size = [long]$file.Length
                Remove-Item -LiteralPath $fullPath -Force -ErrorAction Stop
                $deleted++
                $saved += $size
            }
            catch {
                $failed++
            }
        }
    }

    [PSCustomObject]@{
        DeletedFiles = $deleted
        FailedFiles = $failed
        SavedMB = [math]::Round($saved / 1MB, 2)
        Categories = ($Categories -join ", ")
    }
}
