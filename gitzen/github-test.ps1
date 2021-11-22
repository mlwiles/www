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

$DEBUG = 1
$TESTING = 1    

# include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\ghe-common.ps1")
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
}

try {
   Write-Host "g_githubToken = $g_githubToken"
   Write-Host "g_githubOwner = $g_githubOwner"
   Write-Host "g_githubRepository = $g_githubRepository"
   Write-Host "g_githibLabel = $g_githibLabel"
}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Throw "VCD-Github-Generator: $ErrorMessage $FailedItem"
}