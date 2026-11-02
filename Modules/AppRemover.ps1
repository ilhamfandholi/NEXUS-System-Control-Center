function Get-NexusInstalledApps {
    $apps = @()

    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($key in $keys) {
        $entries = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue

        foreach ($entry in $entries) {
            if (
                $entry.DisplayName -and
                -not $entry.SystemComponent -and
                -not $entry.ParentKeyName -and
                $entry.DisplayName -notmatch '^[{]?[0-9A-Fa-f-]{36}[}]?$'
            ) {
                $apps += [PSCustomObject]@{
                    Name = [string]$entry.DisplayName
                    Version = [string]$entry.DisplayVersion
                    Publisher = [string]$entry.Publisher
                    Type = "Desktop"
                    UninstallCommand = [string]$entry.UninstallString
                    QuietCommand = [string]$entry.QuietUninstallString
                    PackageFullName = ""
                }
            }
        }
    }

    $packages = @(Get-AppxPackage -ErrorAction SilentlyContinue)

    foreach ($package in $packages) {
        if (
            $package.Name -and
            -not $package.IsFramework -and
            -not $package.IsResourcePackage -and
            -not $package.NonRemovable -and
            $package.Name -notmatch '^[{]?[0-9A-Fa-f-]{36}[}]?$'
        ) {
            $apps += [PSCustomObject]@{
                Name = [string]$package.Name
                Version = [string]$package.Version
                Publisher = [string]$package.Publisher
                Type = "Microsoft Store"
                UninstallCommand = ""
                QuietCommand = ""
                PackageFullName = [string]$package.PackageFullName
            }
        }
    }

    $apps | Sort-Object Name, Type -Unique
}

function Remove-NexusInstalledApp {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateSet("Desktop", "Microsoft Store")]
        [string]$Type
    )

    $app = Get-NexusInstalledApps |
        Where-Object { $_.Name -eq $Name -and $_.Type -eq $Type } |
        Select-Object -First 1

    if (-not $app) {
        throw "Aplikasi tidak ditemukan."
    }

    if ($Type -eq "Microsoft Store") {
        Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
        return "Perintah penghapusan paket berhasil dijalankan."
    }

    $command = if ($app.QuietCommand) {
        $app.QuietCommand
    } else {
        $app.UninstallCommand
    }

    if (-not $command) {
        throw "Perintah uninstall tidak tersedia."
    }

    if ($command -match '(?i)msiexec(?:\.exe)?\s+.*?({[0-9A-Fa-f-]{36}})') {
        $guid = $Matches[1]
        Start-Process "msiexec.exe" -ArgumentList @("/x", $guid) -Wait
    } else {
        Start-Process -FilePath $env:ComSpec `
            -ArgumentList @("/d", "/s", "/c", "`"$command`"") -Wait
    }

    return "Proses uninstall selesai. Periksa kembali daftar aplikasi."
}
