function Get-NexusNetworkInfo {
    $adapters = @(Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Where-Object { $_.NetAdapter.Status -eq "Up" })

    foreach ($adapter in $adapters) {
        $netAdapter = Get-NetAdapter -InterfaceIndex $adapter.InterfaceIndex `
            -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            Adapter = $adapter.InterfaceAlias
            Status = $netAdapter.Status
            LinkSpeed = $netAdapter.LinkSpeed
            IPv4 = ($adapter.IPv4Address.IPAddress -join ", ")
            Gateway = ($adapter.IPv4DefaultGateway.NextHop -join ", ")
            DNS = ($adapter.DNSServer.ServerAddresses -join ", ")
        }
    }
}

function Test-NexusInternet {
    Test-NetConnection -ComputerName "1.1.1.1" -Port 443 `
        -InformationLevel Detailed -WarningAction SilentlyContinue
}

function Test-NexusPing {
    param(
        [string]$HostName = "1.1.1.1"
    )

    Test-Connection -ComputerName $HostName -Count 4 `
        -ErrorAction SilentlyContinue
}

function Get-NexusDNS {
    param(
        [string]$Domain = "google.com"
    )

    Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop |
        Select-Object Name, Type, IPAddress
}

function Clear-NexusDNS {
    Clear-DnsClientCache
    return "DNS cache berhasil dibersihkan."
}
