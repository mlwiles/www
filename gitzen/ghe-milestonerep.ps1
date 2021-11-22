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
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-provisioning.out"
" " | Out-File $g_filename     

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    "Error while loading supporting PowerShell Scripts" | Out-File $g_filename -Append 
}

$body = '{}'
if ($DEBUG) { "body=$body" | Out-File $g_filename -Append }

for ( $i = 0; $i -lt $args.count; $i++ ) {
  if ($args[ $i ] -eq "/b"){ $body=$args[ $i+1 ]}
  if ($args[ $i ] -eq "-b"){ $body=$args[ $i+1 ]}
}
if ($DEBUG) { "body=$body" | Out-File $g_filename -Append  }

$bodyJSON = $body | ConvertFrom-Json

$assignee = $bodyJSON.assignee
$milestone = $bodyJSON.milestone
$label1 = $bodyJSON.label1
$label2 = $bodyJSON.label2

if ($DEBUG) {
 "assignee: $assignee" | Out-File $g_filename -Append 
 "milestone: $milestone" | Out-File $g_filename -Append 
 "label1: $label1" | Out-File $g_filename -Append 
 "label2: $label2" | Out-File $g_filename -Append 
}

try {
   "entry try section" | Out-File $g_filename -Append 
   $repoId = Get-GithubRepoId 
   "repoId: $repoId" | Out-File $g_filename -Append 

}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $filename -Append
}

[hashtable]$Return = @{} 
$Return.params = [string]"?epicnum="
if ($DEBUG) { "Return.params: " + $Return.Item("params") | Out-File $g_filename -Append }
Return $Return
