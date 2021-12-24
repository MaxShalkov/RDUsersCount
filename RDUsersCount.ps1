param ($server,$type) 

$In = (Get-Content $PSScriptRoot\operational_data.json | ConvertFrom-Json)

if ($server -eq 'all') {
    $In = $In.sessions
} elseif ($server -notin $In.server) {
    return 0
} else {
    $In = ($In | Where-Object {$_.Server -eq $server}).sessions
}

foreach ($tmp in $In) {
    if (($tmp.idle -eq '24692') -or ($tmp.idle -le 3)) {
        $tmp.idle = '.'
    }
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