# List of all known ASR rule GUIDs
$ASRRuleIDs = @(
    "56a863a9-875e-4185-98a7-b882c64b5ce5", # Block abuse of exploited vulnerable signed drivers
    "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c", # Block Adobe Reader from creating child processes
    "D4F940AB-401B-4EFC-AADC-AD5F3C50688A", # Block executable content from email and webmail
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2", # Block credential stealing from LSASS
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550", # Block executable content from email client and webmail
    "01443614-cd74-433a-b99e-2eccc34a4d34", # Use advanced protection against ransomware
    "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC", # Block untrusted and unsigned processes that run from USB
    "D3E037E1-3EB8-44C8-A917-57927947596D", # Block Office apps from creating child processes
    "3B576869-A4EC-4529-8536-B80A7769E899", # Use advanced protection against ransomware
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84", # Block credential stealing from LSASS
    "26190899-1602-49e8-8b27-eb1d0a1ce869", # Block JavaScript or VBScript from launching downloaded executable content
    "E6DB77E5-3DF2-4CF1-B95A-636979351EDE", # Block process creations originating from PSExec and WMI commands
    "D1E49AAC-8F56-4280-B9BA-993A6D77406C", # Block executable files from running unless they meet a prevalence, age, or trusted list criteria
    "33ddedf1-c6e0-47cb-833e-de6133960387", # Block rebooting machine in Safe Mode
    "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4", # Block Office communication application from creating child processes
    "c0033c00-d16d-4114-a5a0-dc9b3a7d2ceb", # Block use of copied or impersonated system tools	
    "a8f5898e-1dc8-49a9-9878-85004b8a61e6", # Block Webshell creation for Servers
    "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b", # Block Win32 API calls from Office macros
    "C1DB55AB-C21A-4637-BB3F-A12568109D35"  # Use advanced protection against ransomware
)
foreach ($id in $ASRRuleIDs) {
    Write-Host "Disabling ASR Rule: $id"
    Add-MpPreference -AttackSurfaceReductionRules_Ids $id -AttackSurfaceReductionRules_Actions Disabled
}

Write-Host "❌ All ASR rules have been disabled."
