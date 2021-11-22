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
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-pipelines.out"
$g_HTMLfilename = "C:\inetpub\wwwroot\gitzen\ghe-pipelines.html"
" " | Out-File $g_filename   
" " | Out-File $g_HTMLfilename   

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    "Error while loading supporting PowerShell Scripts" | Out-File $g_filename -Append 
}

try {
    # -- Pipelines --
    $repoId = Get-GithubRepoId
    $getpipelines = Get-ZenhubPipelines -repoId $repoId
    
    $pipelines = $getpipelines.pipelines
    foreach ($pipeline in $pipelines) {
       $pipeid = $pipeline.id
       $pipename = $pipeline.name
       "<option value='$pipeid'>$pipename</option>" | Out-File $g_HTMLfilename -Append 
    }
}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $g_filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $g_filename -Append
}


