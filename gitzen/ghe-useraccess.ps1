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
$g_filename = "C:\inetpub\wwwroot\gitzen\ghe-endofmonth.out"
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

$date = $bodyJSON.date
$assignee = $bodyJSON.assignee
$milestone = $bodyJSON.milestone
$pipeline = $bodyJSON.pipeline
$label1 = $bodyJSON.label1
$label2 = $bodyJSON.label2

if ($DEBUG) {
 "date: $date" | Out-File $g_filename -Append 
 "assignee: $assignee" | Out-File $g_filename -Append 
 "milestone: $milestone" | Out-File $g_filename -Append 
 "pipeline: $pipeline" | Out-File $g_filename -Append 
 "label1: $label1" | Out-File $g_filename -Append 
 "label2: $label2" | Out-File $g_filename -Append 
}

try {
   "entry try section" | Out-File $g_filename -Append 
   $repoId = Get-GithubRepoId 
   "repoId: $repoId" | Out-File $g_filename -Append 
   #######################################
   #Create issue and promote issue to Epic
   #######################################
   $newIssueId = New-GithubIssue -title "EPIC: User Access Quarterly Revalidation : $date" -description "Customer: $customer<br>Date: $date" -labels $label1  
   "newIssueId: $newIssueId" | Out-File $g_filename -Append 
   $epicIssueId = Convert-ZenhubIssueToEpic -repoId $repoId -issueId $newIssueId
   if ($assignee -notcontains "none") {
      $nothing = Set-GithubAssignee -issueId $newIssueId -assignee $assignee
   }
   if ($milestone -notcontains "none") {
      $nothing = Set-GithubMilestone -issueId $newIssueId -milestone $milestone
   }
   if ($pipeline -notcontains "none") {
      $nothing = Set-ZenhubPipeline -repoId $repoId -issueId $newIssueId -pipeline $pipeline
   } 

   ####################################
   #Create issues and associate to Epic
   ####################################
   $nothing = New-GHIssue-ZenhubUpdates -title "Softlayer User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "W3-communities User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Veeam User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "VMWare User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Pingdom User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Zabbix User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Network User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Salesforce User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Service User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Github User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Pagerduty User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "SOS User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Maintenance User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Functional IDs User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
   $nothing = New-GHIssue-ZenhubUpdates -title "Customer Enviroment Accounts User Access Quarterly Revalidation : $date" -description "" -labels $label1 -repoId $repoId -epicId $epicIssueId -estimate 1 -assignee $assignee -milestone $milestone -pipeline $pipeline
}
catch {
    "Exception.Message:$_.Exception.Message" | Out-File $filename -Append
    "Exception.ItemName:$_.Exception.ItemName" | Out-File $filename -Append
}

[hashtable]$Return = @{} 
$Return.params = [string]"?epicnum=$epicIssueId&dcenter=$dcenter&customer=$customer&offering=$offering&version=$version&type=$type&contact=$contact&assignee=$assignee"
if ($DEBUG) { "Return.params: " + $Return.Item("params") | Out-File $g_filename -Append }
Return $Return
