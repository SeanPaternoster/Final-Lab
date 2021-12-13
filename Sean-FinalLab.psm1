Function Test-CloudFlare {
#

<#
.SYNOPSIS
Conducting a ping test on a remote computer.
.DESCRIPTION
User is told to give a computer name or address to create a remote session. 
The remote session is then created and used to ping the address 'one.one.one.one.'
.PARAMETER Computername
A mandatory parameter to identify the computer used for the script.
.Example
PS C:\powershell test> .\Test-CloudFlare -Computername 192.168.0.207
This will output to display on screen
.NOTES 
Author: Sean Paternoster
Last Edit: 2021-12-13
Version 2.0 - Final Release of Test-CloudFlare
#>
[CmdletBinding()]
#Enables Cmdlet Binding

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Alias('CN', 'Name')][string]$Computername
) #Parameter
#Valid options for output with the default being Host. 
Begin {}
Process{
ForEach ($Computer in $ComputerName) {
    Try {
        $Params = @{
            'ComputerName' = $Computer
            'ErrorAction' = 'Stop'
        } #Try Parameters
    $RemoteSession = New-PSSession @Params
    #variable that makes a new remote session to the computer name.
    Enter-PSSession $RemoteSession
    #Enter remote session
    $TestCF = Test-NetConnection -ComputerName 'One.One.One.One' -InformationLevel Detailed
    #Variable that runs a detailed ping test to 1.1.1.1
    $OBJ =[PSCustomObject]@{
        'ComputerName' = $Computername
        'PingSuccess' = $TestCF.PingSucceeded
        'NameResolve' = $TestCF.NameResolutionSucceeded
        'ResolvedAddresses' = $TestCF.ResolvedAddresses
    } #Custom PSObject props
    #Creates a variable that contains ComputerName and results of the ping test
    $OBJ
    Exit-PSSession
    Remove-PSSession $RemoteSession
    #Creates a new object named $Props. Exits the remote session and removes it.
    }#Try
    Catch{ 
        Write-Host "Remote Connection for $Computer failed" -ForeGroundColor Red
    }#Catch
} #ForEach
} #Process
End {}
} #Function 

function Get-PipeResults {
 <#.
 .SYNOPSIS
Retrieve the results from Get-PipeResults based on user input (Host, txt, CSV.)
.DESCRIPTION
User is told to retrieve results from Get-PipeResults.
.PARAMETER FileName
A parameter to identify the name of the file.
.PARAMETER Multiple
Pulls multiple objects from the pipeline.
.PARAMETER location
User's home directory.
.Example
Get-Process -name *shell | Get-PipeResults
Runs Get-PipeResults and retrieves processes that start with 'shell'. 
.PARAMETER Output
Host is the default output but can also be output as Text and CSV. 
.NOTES 
Author: Sean Paternoster
Last Edit: 2021-12-13
Version 1.0 - Initial Release of Get-PipeResults
#>

[CmdletBinding()]
#Enables Cmdlet Binding
param(
    [Parameter(Mandatory=$false)][string]$location = $env:USERPROFILE,
    [ValidateSet('Host','Text','CSV')]
    [string]$Output = 'Host' ,
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
    [object[]]$Multiple,
    [Parameter(Mandatory=$False)][string]$FileName="PipeResults"
) #Param block

Begin{}
Process{
    switch ($Output) {
        'Host' { Write-Verbose "Generating Results"
                $Multiple}
        'Text' {Write-Verbose "Generating Results as txt file"
            $Multiple | Out-File $location\$FileName.txt
            Write-Verbose "Opening Results"
            notepad.exe $location\$FileName.txt}
            #Opens RemTestNet on Notepad
        'CSV' {Write-Verbose "Generating Results as CSV file"
            $Multiple | Export-CSV $location\$FileName.csv}
    }#Switch 
}#Process
End{}
}#Function