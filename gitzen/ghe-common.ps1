<# 
.SYNOPSIS 
 
 
.DESCRIPTION 
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2019-03-10 
│   AUTHOR      : Michael Wiles (mwiles@us.ibm.com) 
│   DESCRIPTION : Initial Draft 
└─────────────────────────────────────────────────────────────────────────────────────────────┘
 
#> 

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'

 
$g_githubToken = "REDACTED"
$g_githubOwner = "REDACTED"
$g_githubRepository = "REDACTED"
$g_githibLabel = "scrum-Agile Tasks"

if ($TESTING) {
   $g_githubToken = "REDACTED"
   $g_githubOwner = "mwiles" #mwiles/mwiles
   $g_githubRepository = "mwiles" #mwiles/mwiles
   $g_githibLabel = "question"
}

$g_githubURL = "https://api.github.ibm.com"
$g_githubHeaders = @{         
                   'Authorization' = "token $g_githubToken"
}  

$g_zenhubToken = "REDACTED"
$g_zenhubURL = "https://zenhub.ibm.com"
$g_zenhubIssuesJSON = @{
                      issues = @()
} | ConvertTo-Json 

###################################################
#https://developer.github.com/v3/issues/#create-an-issue    
function New-GithubIssue {
   Param([string]$title, [string]$description, [string]$labels)
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/issues"
   $bodyJSON = @{
               title  = "$title"
               body   = "$description"
               labels = @("$labels")
   } | ConvertTo-Json
   $id = -1;   
   $functionName = "New-GithubIssue"
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [title]$title, [description]$description, [labels]$labels" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append  
      }
   }
   
   try {     
      $newIssue = Invoke-RestMethod -Method Post -Uri $url -Body $bodyJSON -Headers $g_githubHeaders -ContentType "application/json"
      $id = $newIssue.number
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [return id]$id" | Out-File $g_filename -Append
      } 
   }
   return $id
}
###################################################
#https://developer.github.com/v3/repos/#get
function Get-GithubRepoId {
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository"
   $id = -1;
   $functionName = "Get-GithubRepoId"
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [g_githubHeaders(""Authorization"")]:" + $g_githubHeaders.Item("Authorization")
      } else {
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [g_githubHeaders(""Authorization"")]:" + $g_githubHeaders.Item("Authorization") | Out-File $g_filename -Append 
      }
   }
   try { 
      $repoDetails = Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
      $id = $repoDetails.id
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [return id]$id" | Out-File $g_filename -Append 
      }
   }
   return $id
}
###################################################
#https://github.com/ZenHubIO/API#convert-issue-to-epic
function Convert-ZenhubIssueToEpic { 
   Param([int]$repoId, [int]$issueId)
   $functionName = "Convert-ZenhubIssueToEpic"
   $url = "$g_zenhubURL/p1/repositories/$repoId/issues/$issueId/convert_to_epic?access_token=$g_zenhubToken"
   $id = -1;
   try {
      $epicIssue = Invoke-RestMethod -Method Post -Uri $url -Body $g_zenhubIssuesJSON -ContentType "application/json"
      $id = $issueId
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [repoId]$repoId, [issueId]$issueId"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [repoId]$repoId, [issueId]$issueId" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [return id]$id" | Out-File $g_filename -Append 
      }
   }
   return $id
}
###################################################
#https://github.com/ZenHubIO/API#add-or-remove-issues-to-epic
function Add-ZenhubIssueToEpic { 
   Param([int]$repoId, [int]$epicId, [int]$issueId)
   $functionName = "Add-ZenhubIssueToEpic"
   $url = "$g_zenhubURL/p1/repositories/$repoId/epics/$epicId/update_issues?access_token=$g_zenhubToken"
   $id = -1;
   $bodyJSON = @{
                  add_issues = @(
                             @{ 
                             repo_id = $repoId
                             issue_number = $issueId
   })} | ConvertTo-Json
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [repoId]$repoId, [epicId]$epicId, [issueId]$issueId"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [bodyJSON]$bodyJSON"
      } else {
         "$functionName : [repoId]$repoId, [epicId]$epicId, [issueId]$issueId" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append
      } 
   }
   try {
      $epicIssue = Invoke-RestMethod -Method Post -Uri $url -Body $bodyJSON -ContentType "application/json"
      $id = $epicId
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [return id]$id" | Out-File $g_filename -Append 
      }
   }
   return $id
}
###################################################
#https://github.com/ZenHubIO/API#set-issue-estimate
function Set-ZenhubEstimation {
   Param([int]$repoId, [int]$issueId, [int]$estimate)
   $functionName = "Set-ZenhubEstimation"
   $url = "$g_zenhubURL/p1/repositories/$repoId/issues/$issueId/estimate?access_token=$g_zenhubToken"
   $bodyJSON = @{
                  estimate = $estimate
   } | ConvertTo-Json
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [repoId]$repoId, [issueId]$issueId, [int]$estimate"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [bodyJSON]$bodyJSON"
      } else {
         "$functionName : [repoId]$repoId, [issueId]$issueId, [int]$estimate" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append 
      }
   }
   try {
      $issueEstimate = Invoke-RestMethod -Method Put -Uri $url -Body $bodyJSON -ContentType "application/json"
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
}
###################################################
#https://developer.github.com/v3/issues/assignees/#add-assignees-to-an-issue
function Set-GithubAssignee {
   Param([int]$issueId, [string]$assignee)
   $functionName = "Set-GithubAssignee"
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/issues/$issueId/assignees"
   $bodyJSON = @{
           assignees = @(
                       $assignee
   )} | ConvertTo-Json
   $id = -1;   
   $functionName = "Set-GithubAssignee"
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [issueId]$issueId, [assignee]$assignee"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [bodyJSON]$bodyJSON"
      } else {
         "$functionName : [issueId]$issueId, [assignee]$assignee" | Out-File $g_filename -Append
         "$functionName : [url]$url" | Out-File $g_filename -Append
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append
      }
   }
      try {     
      $newIssue = Invoke-RestMethod -Method Post -Uri $url -Body $bodyJSON -Headers $g_githubHeaders -ContentType "application/json"
      $id = $newIssue.number
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [return id]$id"
      } else {
         "$functionName : [return id]$id" | Out-File $g_filename -Append 
      }
   }
   return $id
}
###################################################
function Get-GithubMilestones {
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/milestones"
   $functionName = "Get-GithubMilestones"
   $milestonesRt
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [url]$url"
      } else {
         "$functionName : [url]$url" | Out-File $g_filename -Append 
      }
   }
   try {     
      $milestonesRt = Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
      if ($DEBUG) { "$functionName : [milestonesRt]$milestonesRt" | Out-File $g_filename -Append }
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   return $milestonesRt
}
###################################################
#https://developer.github.com/v3/issues/#edit-an-issue  
function Set-GithubMilestone {
   Param([int]$issueId, [int]$milestone)
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/issues/$issueId"
   $bodyJSON = @{
               milestone  = $milestone
   } | ConvertTo-Json
   $milestonesRt   
   $functionName = "Set-GithubMilestone"
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [milestone]$milestone, [issueId]$issueId"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [bodyJSON]$bodyJSON"
      } else {
         "$functionName : [milestone]$milestone, [issueId]$issueId" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append 
      } 
   }
   try {     
      $milestonesRt = Invoke-RestMethod -Method Patch -Uri $url -Body $bodyJSON -Headers $g_githubHeaders -ContentType "application/json"
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [milestonesRt]$milestonesRt"
         } else {
            "$functionName : [milestonesRt]$milestonesRt" | Out-File $g_filename -Append 
         }
      }
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   return $milestonesRt
}

###################################################
#https://developer.github.com/v3/repos/collaborators/
function Get-GithubCollaborators {
   $functionName = "Get-GithubCollaborators"
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/collaborators?per_page=100"
   $collaboratorsRt
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [url]$url"
      } else {
         "$functionName : [url]$url" | Out-File $g_filename -Append 
      }
   }
   try {     
      $collaboratorsRt = Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
      $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/collaborators?per_page=100&page=2"
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [url]$url"
            Write-Host "$functionName : [collaboratorsRt]$collaboratorsRt"
         } else {
            "$functionName : [url]$url" | Out-File $g_filename -Append
            "$functionName : [collaboratorsRt]$collaboratorsRt" | Out-File $g_filename -Append 
         }
      }
      $collaboratorsRt += Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   return $collaboratorsRt
}
###################################################
function Get-GithubUser {
   Param([string]$githublogin)
   $functionName = "Get-GithubUser"
   $url = "$g_githubURL/users/$githublogin"
   $githubUserRt
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [githublogin]$githublogin"
      } else {
         "$functionName : [url]$url" | Out-File $g_filename -Append
         "$functionName : [githublogin]$githublogin" | Out-File $g_filename -Append
      }
   }
   try {     
      $githubUserRt = Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [githubUserRt]$githubUserRt"
         } else {
            "$functionName : [githubUserRt]$githubUserRt" | Out-File $g_filename -Append 
         }
      }
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   return $githubUserRt
}
###################################################
#https://github.com/ZenHubIO/API#get-the-zenhub-board-data-for-a-repository
function Get-ZenhubPipelines {
   Param([int]$repoId)
   $functionName = "Get-ZenhubPipelines"
   $url = "$g_zenhubURL/p1/repositories/$repoId/board?access_token=$g_zenhubToken"
   $pipelinesRt
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [repoId]$repoId"
         Write-Host "$functionName : [url]$url"
      } else {
         "$functionName : [repoId]$repoId" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append 
      }
   }
   try {
      $pipelinesRt = Invoke-RestMethod -Method Get -Uri $url -ContentType "application/json"
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [pipelinesRt]$pipelinesRt"
         } else {
            "$functionName : [pipelinesRt]$pipelinesRt" | Out-File $g_filename -Append 
         }
      }
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   return $pipelinesRt
}
###################################################   
   #https://github.com/ZenHubIO/API#move-an-issue-between-pipelines
function Set-ZenhubPipeline {
   Param([int]$repoId, [int]$issueId, [string]$pipeline)
   $functionName = "Set-ZenhubPipeline"
   $url = "$g_zenhubURL/p1/repositories/$repoId/issues/$issueId/moves?access_token=$g_zenhubToken"
   $bodyJSON = @{
                  pipeline_id = $pipeline
                  position = "top"
   } | ConvertTo-Json
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [repoId]$repoId, [issueId]$issueId, [pipeline]$pipeline"
         Write-Host "$functionName : [url]$url"
         Write-Host "$functionName : [bodyJSON]$bodyJSON"
      } else {
         "$functionName : [repoId]$repoId, [issueId]$issueId, [pipeline]$pipeline" | Out-File $g_filename -Append 
         "$functionName : [url]$url" | Out-File $g_filename -Append  
         "$functionName : [bodyJSON]$bodyJSON" | Out-File $g_filename -Append
      } 
   }
   try {
      $pipelineRT = Invoke-RestMethod -Method Post -Uri $url -Body $bodyJSON -ContentType "application/json"
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [pipelineRT]$pipelineRT"
         } else {
            "$functionName : [pipelineRT]$pipelineRT" | Out-File $g_filename -Append
         }
      }
      return $pipelineRT
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
}
###################################################
#https://developer.github.com/v3/issues/labels/#list-all-labels-for-this-repository
function Get-GithubLabels {
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/labels?per_page=100"
   $functionName = "Get-GithubLabels"
   $labelsRt
   try {     
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [url]$url"
         } else {
            "$functionName : [url]$url" | Out-File $g_filename -Append 
         }
      }
      $labelsRt = Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
      $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/labels?per_page=100&page=2"
      if ($DEBUG) { 
         if ($TESTING) {
            Write-Host "$functionName : [url]$url"
         } else {
            "$functionName : [url]$url" | Out-File $g_filename -Append
         } 
      }
      $labelsRt += Invoke-RestMethod -Method Get -Uri $url -Headers $g_githubHeaders -ContentType "application/json"
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) { 
      if ($TESTING) {
         Write-Host "$functionName : [return labels]$labelsRt"
      } else {
         "$functionName : [return labels]$labelsRt" | Out-File $g_filename -Append 
      }
   }
   return $labelsRt
}
###################################################
function New-GHIssue-ZenhubUpdates {
   Param([string]$title, [string]$description, [string]$labels, [int]$repoId, [int]$epicId, [int]$estimate, [string]$assignee, [string]$milestone, [string]$pipeline)
   $functionName = "New-GHIssue-ZenhubUpdates"
      
   if ($DEBUG) {
      if ($TESTING) {
         Write-Host "$functionName : [title]$title, [description]$description, [labels]$labels, [repoId]$repoId, [epicId]$epicId, [estimate]$estimate"
      } else {
         "$functionName : [title]$title, [description]$description, [labels]$labels, [repoId]$repoId, [epicId]$epicId, [estimate]$estimate" | Out-File $g_filename -Append 
      }
   }
   try {
      $newIssueId = New-GithubIssue -title $title -description $description -labels $labels
      $nothing = Add-ZenhubIssueToEpic -repoId $repoId -epicId $epicId -issueId $newIssueId
      if ($estimate -ne 0) {
         $nothing = Set-ZenhubEstimation -repoId $repoId -issueId $newIssueId -estimate $estimate
      }
      if ($assignee -notcontains "none") {
         $nothing = Set-GithubAssignee -issueId $newIssueId -assignee $assignee
      }
      if ($milestone -notcontains "none") {
         $imilestone = [int]$milestone   
         $nothing = Set-GithubMilestone -issueId $newIssueId -milestone $imilestone
      }
      if ($pipeline -notcontains "none") {
         $nothing = Set-ZenhubPipeline -repoId $repoId -issueId $newIssueId -pipeline $pipeline
      }
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
}
###################################################


