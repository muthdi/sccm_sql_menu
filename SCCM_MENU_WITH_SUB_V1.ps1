# Check if script is being run as an administrator and relauch as admin if not.
Write-Host "$Strng1 Making sure this script is being run as an Administrator, will respawn if needed. 'n"
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
Start-Sleep -s 1

mode 300
write-Host ""
write-Host ""
write-Host ""
write-Host ""
write-Host ""
write-Host ""
write-host "           ###############################################################################################" -ForegroundColor Green
write-host "           ###############################################################################################" -ForegroundColor Green
write-host "           ###############################################################################################" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ######      This script allows you to do most stuff from one place with SCCM  and SQL     #####" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ######                        works as designed , without warranty                        #####" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ######           Version :    V1              2007-2023       @Dieter Muth                #####" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ######                   you can use and extend on your own needs                         #####" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ######        partly you have to play with your credentials  ex : no line 1-4             #####" -ForegroundColor Green
write-host "           ######                                                                                    #####" -ForegroundColor Green
write-host "           ###############################################################################################" -ForegroundColor Green
write-host "           ###############################################################################################" -ForegroundColor Green
write-host "           ###############################################################################################" -ForegroundColor Green

pause


<#  V1 menu and submenu and subsub
            { main menu           } 
        "1" { Show-EXAMPLESubMenu } 

#>
#################################
# Site configuration
cls
write-host ""
write-host "           following we need some informations from you to connect to your site       " -ForegroundColor green
write-host ""
pause

#$SiteCode = "CHQ"                             # Site code 
#$ProviderMachineName = "CM1.corp.contoso.com" # SMS Provider machine name

write-host ""
write-host ""
write-host ""
$SiteCode = read-host "          give me your sidecode  - ex : CHQ "
write-host ""
$ProviderMachineName = read-host " give me your provider machine name   ex: CM1.corp.contoso.com "
write-host ""

# Define SQL Server instance and database
#$SqlServerInstance = "CM1.corp.contoso.com"
#$DatabaseName = "ConfigMgr_CHQ"
#
$SqlServerInstance = read-host " give me your SQL Server Instance  ex: CM1.corp.contoso.com "
write-host ""
$DatabaseName = read-host " give me the name of your SQL database   ex :  ConfigMgr_CHQ "
cls
write-host ""
write-host "          we are using following parameter for your connection : " -ForegroundColor green
write-host "   "
write-host "          $SiteCode   " -ForegroundColor yellow
write-host "          $ProviderMachineName" -ForegroundColor DarkYellow
write-host "          $DatabaseName " -ForegroundColor Yellow
write-host "          $SqlServerInstance" -ForegroundColor DarkYellow
write-host "   "
pause

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$curLocation = Get-Location

# Function to connect to SQL Server
function Connect-SqlServer {
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SqlServerInstance;Database=$DatabaseName;Integrated Security=True"
    $SqlConnection.Open()
    return $SqlConnection
}

# Main script
$SqlConnection = Connect-SqlServer
if ($SqlConnection.State -eq 'Open') {
    Write-Host "   Connected to SQL Server successfully   " -ForegroundColor Green
} else {
    Write-Host "   Failed to connect to SQL Server   " -ForegroundColor Red
}
write-host "   current Location $curLocation " -ForegroundColor green

pause

# Function to execute SQL queries
function Execute-SqlQuery {
    param (
        [string]$query
    )

    $command = $SqlConnection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()

    $dataTable = New-Object System.Data.DataTable
    $dataTable.Load($result)

    $result.Close()
    $dataTable
}

##########################  Main Menu  #######################
## Main Menu
function Show-MainMenu {
    cls
    Write-Host ""
    Write-Host ""
    Write-Host "   Main Menu" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "   1. Examples " -ForegroundColor yellow
    Write-Host ""
    Write-Host "   q. Quit"           -ForegroundColor Green
    Write-Host ""
    $choice = Read-Host "   Enter your choice (1, q):"
    switch ($choice) {
        "1" { Show-EXAMPLESubMenu }

        "q" { Exit                       }
        Default {
            Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
            Show-MainMenu
        }
    }
}

###############   EXAMPLE Submenu ##############
function Show-EXAMPLESubMenu {
    cls
    Write-Host ""
    Write-Host ""
    Write-Host "   EXAMPLES " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. Get " -ForegroundColor yellow
    Write-Host ""
    Write-Host "   b. Back to Main Menu" -ForegroundColor green
    Write-Host ""
    $choice = Read-Host "   Enter your choice (1, b):"
    switch ($choice) {
        "1" { Show-EXAMPLESubMenuGET }
        "b" { Show-MainMenu }
        Default {
            Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
            Show-EXAMPLESubMenu
        }
    }
}

########## Show-EXAMPLESubMenuGET
function Show-EXAMPLESubMenuGET {
    cls
    Write-Host ""
    Write-Host ""
    Write-Host "   Get EXAMPLES " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. Get all Collections by powershell " -ForegroundColor yellow
    Write-Host "   2. Get all Packages by powershell  " -ForegroundColor white
    Write-Host "   3. Get by powershell " -ForegroundColor yellow
    Write-Host "   4. Get all Collections by SQL Query " -ForegroundColor white
    Write-Host "   5. Get all Packages by SQL Query " -ForegroundColor yellow
    Write-Host "   6. Get by SQL " -ForegroundColor white
    Write-Host ""
    Write-Host "   b. Back to EXAMPLES Menu" -ForegroundColor green
    Write-Host ""
    $choice = Read-Host "   Enter your choice (1-6, b):"
    switch ($choice) {
        "1" { Get-EXAMPLES1 }
        "2" { Get-EXAMPLES2 }
        "3" { Get-EXAMPLES3 }
        "4" { Get-EXAMPLES4 }
        "5" { Get-EXAMPLES5 }
        "6" { Get-EXAMPLES6 }
        "b" { Show-EXAMPLESubMenu }
        Default {
            Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
            Show-EXAMPLESubMenuGET
        }
    }
}

#### Function Get-EXAMPLES1
function Get-EXAMPLES1  {
    cls
    Get-CMCollection | Select-Object -Property CollectionID,Name,Comment,LastChangeTime,LastRefreshTime,CollectionType,LimitToCollectionID |out-gridview -Title CollectionsWithPowershell
    Show-EXAMPLESubMenuGET
}

#### Function Get-EXAMPLES2
function Get-EXAMPLES2  {
    cls
    Get-CMPackage -Fast | Select-Object -Property name,PackageID,PkgSourcePath,Version,SourceVersion,SourceDate,PackageSize |Out-GridView -Title allPackagesBYPowershell
    Pause
    Show-EXAMPLESubMenuGET
}

#### Function Get-EXAMPLES3
function Get-EXAMPLES3  {
    cls
    Write-Host "Get 3"
    # Add code to execute Get 3 here
    Pause
    Show-EXAMPLESubMenuGET
}
#### Function Get-EXAMPLES4
function Get-EXAMPLES4  {
    cls
    $query = "SELECT [CollectionID]
      ,[SiteID]
      ,[CollectionName]
      ,[CollectionComment]
      ,[LastChangeTime]
      ,[LastRefreshRequest]
      ,[CollectionType]
      ,[LimitToCollectionID]
      ,[IsReferenceCollection]
      ,[BeginDate]
      ,[EvaluationStartTime]
      ,[LastRefreshTime]
      ,[LastIncrementalRefreshTime]collection
      ,[LastMemberChangeTime]
      ,[CurrentStatus]
      ,[CurrentStatusTime]
      ,[LimitToCollectionName]
      ,[IncludeExcludeCollectionsCount]
      ,[MemberCount]
      ,[LocalMemberCount]
      ,[ObjectPath]
      ,[ServicePartners]
      ,[FullEvaluationRunTime]
      ,[FullEvaluationMemberChanges]
      ,[FullEvaluationMemberChangeTime]
      ,[FullEvaluationLastRefreshTime]
      ,[FullEvaluationNextRefreshTime]
      ,[IncrementalEvaluationRunTime]
      ,[IncrementalEvaluationMemberChanges]
      ,[IncrementalEvaluationMemberChangeTime]
      ,[IncrementalEvaluationLastRefreshTime]
  FROM [ConfigMgr_CHQ].[dbo].[v_Collections]"
    Execute-SqlQuery $query |Out-GridView -Title CollectionsbySQL
    Show-EXAMPLESubMenuGET
}
#### Function Get-EXAMPLES5
function Get-EXAMPLES5  {
    cls
    $query = "SELECT 
       [Name]
	  ,[PkgID]
	  ,[Source]
      ,[Version]
	  ,[StoredPkgVersion]
	  ,[SourceDate]
      ,[SourceSize]

  FROM [ConfigMgr_CHQ].[dbo].[vSMS_Package_List]"
    Execute-SqlQuery $query |Out-GridView -Title PackagesbySQL
    Show-EXAMPLESubMenuGET
}
#### Function Get-EXAMPLES6
function Get-EXAMPLES6  {
    cls
    $query = "SELECT * FROM TableName2"
    Execute-SqlQuery $query
    Pause
    Show-EXAMPLESubMenuGET
}


# Run Main Menu
Show-MainMenu
