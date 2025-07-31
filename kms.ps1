param(
    [string]$Server,
    [string]$Version
    
)

switch ($Version) {
    "2019" { $key = "N69G4-B89J2-4G8F4-WWYCC-J464C" }
    "2022" { $key = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H" }
    default { Write-Host "❌ [ERROR] - Unknown server"; exit 1 }
}

cscript //nologo c:\windows\system32\slmgr.vbs /upk
cscript //nologo c:\windows\system32\slmgr.vbs /ipk $Key
cscript //nologo c:\windows\system32\slmgr.vbs /ipk $Key
cscript //nologo c:\windows\system32\slmgr.vbs /skms $server:1688
cscript //nologo c:\windows\system32\slmgr.vbs /ato




