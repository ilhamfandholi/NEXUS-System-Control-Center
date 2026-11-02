function Get-NexusStartupList {
    $items = @()

    $keys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($key in $keys) {
        if (Test-Path $key) {
            $properties = Get-ItemProperty -Path $key
            foreach ($property in $properties.PSObject.Properties) {
                if ($property.Name -notmatch '^PS') {
                    $items += [PSCustomObject]@{
                        Name = $property.Name
                        Command = [string]$property.Value
                        Location = $key
                        Type = "Registry"
                    }
                }
            }
        }
    }

    $folders = @(
        [Environment]::GetFolderPath("Startup"),
        [Environment]::GetFolderPath("CommonStartup")
    )

    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Get-ChildItem -LiteralPath $folder -File -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $items += [PSCustomObject]@{
                        Name = $_.BaseName
                        Command = $_.FullName
                        Location = $folder
                        Type = "Startup Folder"
                    }
                }
        }
    }

    return $items
}

function Get-NexusScheduledStartup {
    Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object {
        $_.State -ne "Disabled" -and
        ($_.Triggers | Where-Object {
            $_.CimClass.CimClassName -match "BootTrigger|LogonTrigger"
        })
    } |
    ForEach-Object {
        [PSCustomObject]@{
            Name = $_.TaskName
            Command = ($_.Actions | ForEach-Object {
                "$($_.Execute) $($_.Arguments)"
            }) -join "; "
            Location = $_.TaskPath
            Type = "Scheduled Task"
        }
    }
}
