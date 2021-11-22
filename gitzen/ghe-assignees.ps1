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
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-assignees.out"
$g_HTMLfilename = "C:\inetpub\wwwroot\gitzen\ghe-assignees.html"
" " | Out-File $g_filename   
"<option value='none'>** No Assignee **</option>" | Out-File $g_HTMLfilename   

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    "Error while loading supporting PowerShell Scripts" | Out-File $g_filename -Append 
}

try {
    # -- Collaborators --
    $getassignees = Get-GithubCollaborators | Sort-Object -Property login
    foreach ($assignee in $getassignees) {
       $aid = $assignee.id 
       $alogin = [string]$assignee.login
       "Login(UID): $alogin($aid)" | Out-File $g_filename -Append 
       $auser = Get-GithubUser $alogin
       $aname = $auser.name
       "Username: $aname" | Out-File $g_filename -Append 
       "<option value='$alogin'>$aname ($alogin)</option>" | Out-File $g_HTMLfilename -Append 
    }
}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $g_filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $g_filename -Append
}


