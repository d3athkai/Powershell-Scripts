set-executionpolicy remotesigned

$theHostname = $env:COMPUTERNAME + ".txt"
Get-wmiobject win32_processor | select Name,NumberOfCores,NumberOfLogicalProcessors | Out-File -append $theHostname
Get-wmiobject win32_operatingsystem | select caption | Out-File -append $theHostname
Get-wmiobject win32_physicalmemory | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)} | Out-File -append $theHostname