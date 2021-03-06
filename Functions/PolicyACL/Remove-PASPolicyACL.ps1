﻿function Remove-PASPolicyACL{
<#
.SYNOPSIS
Delete all privileged commands on policy

.DESCRIPTION
Deletes all privileged command rules associated with the policy

.PARAMETER PolicyID
String value of Policy ID

.PARAMETER Id
The Rule Id that will be deleted

.PARAMETER sessionToken
Hashtable containing the session token returned from New-PASSession

.PARAMETER WebSession
WebRequestSession object returned from New-PASSession

.PARAMETER BaseURI
PVWA Web Address
Do not include "/PasswordVault/"

.EXAMPLE

.INPUTS
SessionToken, PolicyID, webSession & BaseURI can be piped
by property name

.OUTPUTS
None

.NOTES

.LINK

#>
    [CmdletBinding()]  
    param(
        [parameter(
            Mandatory=$true,
            ValueFromPipelinebyPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string]$PolicyID,

        [parameter(
            Mandatory=$true
        )]
        [string]$Id,
          
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

        #Create base URL for request
        $URI = "$baseURI/PasswordVault/WebServices/PIMServices.svc/Policy/$($PolicyID | 
        
            Get-EscapedString)/PrivilegedCommands/$($Id | 
                
                Get-EscapedString)"
        
        #send request to web service
        Invoke-PASRestMethod -Uri $URI -Method DELETE -Headers $sessionToken -WebSession $WebSession

    }#process

    END{}#end

}