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
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-milestones.out"
$g_HTMLfilename = "C:\inetpub\wwwroot\gitzen\ghe-milestones.html"
" " | Out-File $g_filename   
"<option value='none'>** No Milestone **</option>" | Out-File $g_HTMLfilename     

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    "Error while loading supporting PowerShell Scripts" | Out-File $g_filename -Append 
}

try {
    # -- Milestones --
    $getmilestones = Get-GithubMilestones
    foreach ($getmilestone in $getmilestones) {
       $mid = $getmilestone.number 
       $mname = $getmilestone.title
       "Name(id): $mname($mid)" | Out-File $g_filename
       if ($mid.length -gt 0) {
          "<option value='$mid'>$mname</option>" | Out-File $g_HTMLfilename -Append 
       }
    }
}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $g_filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $g_filename -Append
}


