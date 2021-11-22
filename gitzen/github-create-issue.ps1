#Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

#https://invoke-automation.blog/2018/10/27/use-powershell-to-create-a-github-issues/
# function New-GithubIssue {
#    <#
#	.DESCRIPTION - Creates a GitHub issue via a REST API
#    .PARAMETER Title - A Title is Required
#    .PARAMETER Description - A Description for the issue is required.
#    .PARAMETER Label - An Issue Label is required, and must already exist!
#    .PARAMETER Owner -  - An Owner/Org is required.
#    .PARAMETER Repository - A Repository Name is required.
#    .PARAMETER Headers - A Repository Name is required.
#    .EXAMPLE
#        $UserToken = "REDACTED"
#        $Headers = @{Authorization = 'token ' + $UserToken}
#        New-GithubIssue -Title "My New Issue" -Description "Sliced Bread" -Label "Automation" -owner "jpsider" -Repository "Invoke-Automation" -Headers ""
#	.NOTES - It will create the issue in GitHub. It requires Headers that include an API token.
#    .LINK - http://invoke-automation.blog
#    #>
#    [CmdletBinding(
#        SupportsShouldProcess = $true,
#        ConfirmImpact = "Low"
#    )]
#    [OutputType([String])]
#    [OutputType([boolean])]
#    param(
#        [Parameter(Mandatory=$true)][string]$Title,
#        [Parameter(Mandatory=$true)][string]$Description,
#        [Parameter(Mandatory=$true)][string]$Label,
#        [Parameter(Mandatory=$true)][string]$Owner,
#        [Parameter(Mandatory=$true)][string]$Repository,
#        [Parameter(Mandatory=$true)]$Headers
#    )
#
#    begin {
#        $Body = @{
#                title  = "$Title"
#                body   = "$Description"
#                labels = @("$label")
#            } | ConvertTo-Json
#        }
#    process {
#        if ($pscmdlet.ShouldProcess("Creating issue $Title in GitHub Repo: $Repository."))
#        {
#            try {
#                $NewIssue = Invoke-RestMethod -Method Post -Uri "https://api.github.ibm.com/repos/$owner/$repository/issues" -Body $Body -Headers $Headers -ContentType "application/json"
#                $NewIssue.html_url
#            }
#            Catch {
#                $ErrorMessage = $_.Exception.Message
#                $FailedItem = $_.Exception.ItemName
#                Throw "New-GitHubIssue: $ErrorMessage $FailedItem"
#            }
#        } else {
#            Return $false
#        }
#    }
#}
#$csvFile = "C:\Temp\NewIssues.csv"
#$Content = Get-Content -Path $csvFile
#foreach($line in $Content) {
#$Title,$Description,$Label=$line.split(",")
#Write-Output"Entering Issue - Title:$Title,Description:$description,Label:$Label"
#New-GithubIssue-Title $Title-Description $Description-Label $Label-owner $Owner-    Repository $Repository-Headers $Headers
#}

#https://developer.github.com/v3/issues/#create-an-issue    
#https://github.com/ZenHubIO/API#convert-issue-to-epic
#https://github.com/ZenHubIO/API#add-or-remove-issues-to-epic

$g_githubToken = "REDACTED" #fssops
$g_githubOwner = "REDACTED"                             #fc-cloud-ops/dev-ops-tasks
$g_githubRepository = "REDACTED"                        #fc-cloud-ops/dev-ops-tasks
$g_githibLabel = "scrum-Agile Tasks"

#$g_githubToken = "REDACTED"  #mwiles
#$g_githubOwner = "mwiles"                                    #mwiles/mwiles
#$g_githubRepository = "mwiles"                               #mwiles/mwiles
#$g_githibLabel = "question"

$g_githubURL = "https://api.github.ibm.com"
$g_githubHeaders = @{         
                   'Authorization' = "token $g_githubToken"
}  

$g_zenhubToken = "REDACTED"
$g_zenhubURL = "https://zenhub.ibm.com"
$g_zenhubIssuesJSON = @{
                      issues = @()
} | ConvertTo-Json

$DEBUG = 1

###################################################
function New-GithubIssue {
   Param([string]$title, [string]$description, [string]$label)
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/issues"
   $body = @{
           title  = "$title"
           body   = "$description"
           labels = @("$label")
   } | ConvertTo-Json
   $id = -1;   
   $functionName = "New-GithubIssue"
   try {     
      $newIssue = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $g_githubHeaders -ContentType "application/json"
      $id = $newIssue.number
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      Write-Host "$functionName : [title]$title, [description]$description, [label]$label"
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [body]$body"
      Write-Host "$functionName : [return id]$id"
   }
   return $id
}
###################################################
function Get-GithubRepoId {
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository"
   $id = -1;
   $functionName = "Get-GithubRepoId"
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
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [return id]$id"
   }
   return $id
}
###################################################
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
      Write-Host "$functionName : [repoId]$repoId, [issueId]$issueId"
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [return id]$id"
   }
   return $id
}
###################################################
function Add-ZenhubIssueToEpic { 
   Param([int]$repoId, [int]$epicId, [int]$issueId)
   $functionName = "Add-ZenhubIssueToEpic"
   $url = "$g_zenhubURL/p1/repositories/$repoId/epics/$epicId/update_issues?access_token=$g_zenhubToken"
   $id = -1;
   $addIssuesJSON = @{
                  add_issues = @(
                             @{ 
                             repo_id = $repoId
                             issue_number = $issueId
   })} | ConvertTo-Json
   if ($DEBUG) {
      Write-Host "$functionName : [repoId]$repoId, [epicId]$epicId, [issueId]$issueId"
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [addIssuesJSON]$addIssuesJSON"
      Write-Host "$functionName : [return id]$id"
   }
   try {
      $epicIssue = Invoke-RestMethod -Method Post -Uri $url -Body $addIssuesJSON -ContentType "application/json"
      $id = $epicId
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      Write-Host "$functionName : [repoId]$repoId, [epicId]$epicId, [issueId]$issueId"
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [addIssuesJSON]$addIssuesJSON"
      Write-Host "$functionName : [return id]$id"
   }
   return $id
}
###################################################
function Set-ZenhubEstimation {
   Param([int]$repoId, [int]$issueId, [int]$estimate)
   $functionName = "Set-ZenhubEstimation"
   $url = "$g_zenhubURL/p1/repositories/$repoId/issues/$issueId/estimate?access_token=$g_zenhubToken"

   $estimateJSON = @{
                  estimate = $estimate
   } | ConvertTo-Json
   if ($DEBUG) {
      Write-Host "$functionName : [repoId]$repoId, [issueId]$issueId, [int]$estimate" 
      Write-Host "$functionName : [url]$url" 
      Write-Host "$functionName : [estimateJSON]$estimateJSON" 
   }
   try {
      $issueEstimate = Invoke-RestMethod -Method Put -Uri $url -Body $estimateJSON -ContentType "application/json"
   } catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
}
###################################################
function Set-GithubAssignee {
   Param([int]$issueId, [string]$assignee)
   $functionName = "Set-GithubAssignee"
   $url = "$g_githubURL/repos/$g_githubOwner/$g_githubRepository/issues/$issueId/assignees"
   $body = @{
           assignees = @(
                       $assignee
   )} | ConvertTo-Json
   $id = -1;   
   $functionName = "Set-GithubAssignee"
   try {     
      $newIssue = Invoke-RestMethod -Method Post -Uri $url -Body $body -Headers $g_githubHeaders -ContentType "application/json"
      $id = $newIssue.number
   }
   catch {
      $errorMessage = $_.Exception.Message
      $failedItem = $_.Exception.ItemName
      Throw "$functionName : $errorMessage $failedItem"
   }
   if ($DEBUG) {
      Write-Host "$functionName : [issueId]$issueId, [assignee]$assignee"
      Write-Host "$functionName : [url]$url"
      Write-Host "$functionName : [body]$body"
      Write-Host "$functionName : [return id]$id"
   }
   return $id
}
###################################################

 try {
    $repoId = Get-GithubRepoId 
    $newIssueId = New-GithubIssue -title "This will be an Epic" -description "Epic Stuff will go here" -label $g_githibLabel
    $epicIssueId = Convert-ZenhubIssueToEpic $repoId $newIssueId

    $newIssueId = New-GithubIssue -title "This issue goes to the Epic $newIssueId" -description "I have lots of issues" -label $g_githibLabel
    Add-ZenhubIssueToEpic -repoId $repoId -epicId $epicIssueId -issueId $newIssueId
    Set-ZenhubEstimation -repoId $repoId -issueId $newIssueId -estimate 1
    Set-GithubAssignee -issueId $newIssueId -assignee "mwiles"
}
Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Throw "WFSS-Github-Generator: $ErrorMessage $FailedItem"
}