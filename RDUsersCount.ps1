param ($server, $Type)
    
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")

$query = (quser /server:$server | Out-String)

$Out = $query -split "`r" | Select-Object -Skip 1 | ForEach-Object {
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

switch ($Type) {
    "Active" {
        return ($Out | Where-Object {$_.State -match 'Active|Активно'}).username.count
        
    }
    "Disconnect" {
        return ($Out | Where-Object {$_.State -match 'Disc|Диск'}).username.count
        
    }
    default {
        return $Out.username.count
    }
}
