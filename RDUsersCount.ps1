param ($server, $Type)
    
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")

$query = quser /server:$server 

$out = $query -split "`r" |select -Skip 1 | foreach {
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
        return ($out | ? State -eq Active).username.count
    }
    "Диск" {
        return ($out | ? State -eq 'Disconnect').username.count
    }
    default {
        return $out.username.count
    }
}


