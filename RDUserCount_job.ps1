$Result = @()

$Servers = (Get-ADGroupMember RDSH).name -Match "RDS\d+$" | ForEach-Object {$_ + ".$($env:USERDNSDOMAIN)"}

foreach ($s in $Servers) {
    if (-not (Test-Connection $s -Quiet -Count 1 -ErrorAction SilentlyContinue)) {continue} else {

        $Out = (quser /server:$s | Out-String) -split "`r" | Select-Object -Skip 1 | ForEach-Object {
            if ($_ -match  '(?''UserName''[^\>\s]+)\s+(?''SessionName''\S+)?\s+(?''ID''\d+)\s+(?''State''\w+)\s+(?''idle''\d+|\.)'){
              [pscustomobject]@{
                 UserName = $Matches['UserName']
                 ID = $Matches['ID']
                 State = $Matches['State']
                 SessionName = $Matches['SessionName']
                 Idle = $Matches['Idle']
              }
           }
        }

        $Result += [pscustomobject]@{
            Server = $s
            Sessions = $Out
        }
    }
}

$Result | ConvertTo-Json -Depth 3 | Out-File $PSScriptRoot\operational_data.json -Force -Confirm:$false -Encoding utf8
