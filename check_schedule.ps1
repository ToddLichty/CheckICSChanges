Import-Module PSLogging

function Write-LogEntry($message) {
	#Log entry to the log file
	$logFile = 'f:\scripts\schedule\log.txt'
	Write-LogInfo -LogPath $logFile -Message "$(get-date -f yyyy-MM-dd-HHmmss) $message"
}

$source = "http://tcmha.ca/webcal.ashx?IDs=1147"
$destination = "F:\scripts\schedule\schedule_new.ics"
$previous = "F:\scripts\schedule\schedule_old.ics"

Invoke-WebRequest $source -OutFile $destination

if ((Get-FileHash $destination).Hash -ne (Get-FileHash $previous).Hash) {
	$difs = Compare-Object -ReferenceObject (Get-Content $destination) -DifferenceObject (Get-Content $previous) | Out-String
	Write-LogEntry "Diffs found."
	Write-LogEntry $difs
	send-mailmessage -from "tlichty@sherpamarketing.ca" -to "tlichty@sherpamarketing.ca" -subject "Calendar changed" -body $difs -smtpServer 10.0.0.5
	xcopy $destination $previous /y
} else {
	Write-Host "Nothing changed"
	Write-LogEntry "Nothing changed."
}
