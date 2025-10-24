# List of all known ASR rule GUIDs
$ASRRuleIDs = @(
    "D4F940AB-401B-4EFC-AADC-AD5F3C50688A", # Block executable content from email and webmail
    "3B576869-A4EC-4529-8536-B80A7769E899", # Use advanced protection against ransomware
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84", # Block credential stealing from LSASS
    "D3E037E1-3EB8-44C8-A917-57927947596D", # Block Office apps from creating child processes
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84", # Block credential stealing from LSASS
    "DCB9C6F7-4C50-4E1E-9480-1E76C6E3C5D8", # Block persistence through WMI event subscription
    "E6DB77E5-3DF2-4CF1-B95A-636979351EDE", # Block process creations originating from PSExec and WMI commands
    "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC", # Block untrusted and unsigned processes that run from USB
    "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4", # Block Office communication application from creating child processes
    "C1DB55AB-C21A-4637-BB3F-A12568109D35", # Use advanced protection against ransomware
    "9E6B8E18-3B75-4B1E-AC17-4A72AFAE74B3", # Block credential stealing from LSASS
    "3B576869-A4EC-4529-8536-B80A7769E899", # Block Office apps from injecting code into other processes
    "26190899-1602-49e8-8b27-eb1d0a1ce869", # Block JavaScript or VBScript from launching downloaded executable content
    "D1E49AAC-8F56-4280-B9BA-993A6D77406C", # Block executable files from running unless they meet a prevalence, age, or trusted list criteria
    "01443614-cd74-433a-b99e-2eccc34a4d34", # Use advanced protection against ransomware
    "6C6E6E8F-2E3E-4F3C-ABF9-1B0A9A3F0A3C"  # Block credential stealing from LSASS
)

foreach ($id in $ASRRuleIDs) {
    Write-Host "Enabling ASR Rule: $id"
    Add-MpPreference -AttackSurfaceReductionRules_Ids $id -AttackSurfaceReductionRules_Actions Enabled
}

Write-Host "✅ All ASR rules have been enabled."
