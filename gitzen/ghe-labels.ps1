<# 
.SYNOPSIS 
 
 
.DESCRIPTION 
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2019-05-02 
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Initial Draft 
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#> 

$DEBUG = 1
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-labels.out"
$g_HTMLfilename = "C:\inetpub\wwwroot\gitzen\ghe-labels.html"
" " | Out-File $g_filename   
"<option value='none'>** None **</option>" | Out-File $g_HTMLfilename   

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    "Error while loading supporting PowerShell Scripts" | Out-File $g_filename -Append 
}

try {
    # -- Labels --
    $getLabels = Get-GithubLabels | Sort-Object -Property name
    foreach ($getLabel in $getLabels) {
       $lid = $getLabel.id 
       $lname = $getLabel.name
       "Label(id): $lname($lid)" | Out-File $g_filename
       "<option value='$lname'>$lname</option>" | Out-File $g_HTMLfilename -Append    
    }
}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $g_filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $g_filename -Append
}


