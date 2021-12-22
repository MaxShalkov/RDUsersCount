param ($server, $Type)
    
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")

$query = quser /server:$server 

$out = $query -split "`r" | Select-Object -Skip 1 | ForEach-Object {
    if ($_ -match  '(?''UserName''[^\>\s]+)\s+(?''SessionName''\S+)?\s+(?''ID''\d+)\s+(?''State''\w+)\s+(?''idle''\d+|\.)'){
        [pscustomobject]@{
            UserName = $Matches['UserName']
            ID = $Matches['ID']
            State = $Matches['State']
            SessionName = $Matches['SessionName']
            Idle = $Matches['idle']
        }
    }
}

switch ($Type) {
    "Активно" {
        return ($out | Where-Object {$_.State -eq 'Active'}).username.count
    }
    "Диск" {
        return ($out | Where-Object {$_.State -eq 'Disconnect'}).username.count
    }
    default {
        return $out.username.count
    }
}


