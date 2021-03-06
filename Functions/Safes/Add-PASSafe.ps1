﻿function Add-PASSafe{
<#
.SYNOPSIS
Adds a new safe to the Vault

.DESCRIPTION
Adds a new safe to the Vault.
The "Add Safes" permission is required in the vault.

.PARAMETER SafeName
The name of the safe to create.
Max Length 28 characters.
Cannot start with a space.
Cannot contain: '\','/',':','*','<','>','"','.' or '|'

.PARAMETER Description
Description of the new safe.
Max 100 characters.

.PARAMETER OLACEnabled
Boolean value, dictatign whether or not to enable Object Level Access Control on the safe.

.PARAMETER ManagingCPM
The Name of the CPM user to manage the safe.
Specify "" to prevent CPM management.

.PARAMETER NumberOfVersionsRetention
The number of retained versions of every password that is stored in the Safe.
Max value = 999
Specify either this parameter or NumberOfDaysRetention. 

.PARAMETER NumberOfDaysRetention
The number of days for which password versions are saved in the Safe.
Minimum Value: 1
Maximum Value 3650
Specify either this parameter or NumberOfVersionsRetention

.PARAMETER sessionToken
Hashtable containing the session token returned from New-PASSession

.PARAMETER WebSession
WebRequestSession object returned from New-PASSession

.PARAMETER BaseURI
PVWA Web Address
Do not include "/PasswordVault/"

.EXAMPLE

.INPUTS
SessionToken, WebSession & BaseURI can be piped to the function by propertyname

.OUTPUTS
None

.NOTES

.LINK

#>
    [CmdletBinding()]  
    param(
        [parameter(
            Mandatory=$true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -notmatch ".*(\\|\/|:|\*|<|>|`"|\.|\||^\s).*"})]
        [ValidateLength(0,28)]
        [string]$SafeName,

        [parameter(
            Mandatory=$false
        )]
        [ValidateLength(0,100)]
        [string]$Description,

        [parameter(
            Mandatory=$false
        )]
        [boolean]$OLACEnabled,

        [parameter(
            Mandatory=$false
        )]
        [string]$ManagingCPM,

        [parameter(
            Mandatory=$true,
            ParameterSetName="Versions"
        )]
        [ValidateRange(1,999)]
        [int]$NumberOfVersionsRetention,

        [parameter(
            Mandatory=$true,
            ParameterSetName="Days"
        )]
        [ValidateRange(1,3650)]
        [int]$NumberOfDaysRetention,
          
        [parameter(
            Mandatory=$true,
            ValueFromPipelinebyPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [hashtable]$sessionToken,

        [parameter(
            ValueFromPipelinebyPropertyName=$true
        )]
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,

        [parameter(
            Mandatory=$true,
            ValueFromPipelinebyPropertyName=$true
        )]
        [string]$BaseURI
    )

    BEGIN{}#begin

    PROCESS{

        #Create URL for request
        $URI = "$baseURI/PasswordVault/WebServices/PIMServices.svc/Safes"

        #create request body
        $body = @{
                    
                    #add parameters to safe node
                    "safe" = $PSBoundParameters | Get-PASParameters

                } | ConvertTo-Json
        
        #send request to web service
        $result = Invoke-PASRestMethod -Uri $URI -Method POST -Body $Body -Headers $sessionToken -WebSession $WebSession

    }#process

    END{$result.AddSafeResult}#end
}