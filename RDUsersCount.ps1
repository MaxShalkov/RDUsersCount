param ($server,$type) 

$In = (Get-Content $PSScriptRoot\operational_data.json | ConvertFrom-Json)

if ($server -eq 'All') {
    $In = $In.sessions
} elseif ($server -notin $In.server) {
    return 0
} else {
    $In = ($In | Where-Object {$_.Server -eq $server}).sessions
}

switch ($Type) {

    "A" {
        return @($In | Where-Object {($_.State -match 'Active|Активно') -and ($_.Idle -eq ".")}).count
    }

    "D" {
        return @($In | Where-Object {$_.State -match 'Disc|Диск'}).count
    }

    "I" {
        return @($In | Where-Object {($_.Idle -ne '.') -and ($_.State -notmatch 'Disc|Диск')}).count
    }

    default {
        return @($In).count
    }
}