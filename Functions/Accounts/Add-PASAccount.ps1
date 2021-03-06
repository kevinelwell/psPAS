﻿function Add-PASAccount{
<#
.SYNOPSIS
Adds a new privileged account to the Vault

.DESCRIPTION
Adds a new privileged account to the Vault.
Parameters are processed to create request object from passed parameters in the required format.

.PARAMETER Safe
The safe where the account will be created

.PARAMETER PlatformID
The CyberArk platform to assign to the account

.PARAMETER Address
The Address of the machine where the account will be used

.PARAMETER AccountName
The name of the account

.PARAMETER Password
The password value

.PARAMETER Username
Username ont he target machine

.PARAMETER DisableAutoMgmt
Whether or not automatic management wll be disbaled for the account

.PARAMETER DisableAutoMgmtReason
The reason why automatic management wll be disbaled for the account

.PARAMETER GroupName
A groupname with which the account will be associated

.PARAMETER GroupPlatformID
Group platform to base created group ID on, if ID doesn't exist

.PARAMETER Port
Port number over which the account will be used

.PARAMETER ExtraPass1Name
Logon account name

.PARAMETER ExtraPass1Folder
Folder where logon account is stored

.PARAMETER ExtraPass1Safe
Safe where logon account is stored

.PARAMETER ExtraPass3Name
Reconcile account name

.PARAMETER ExtraPass3Folder
Folder where reconcile account is stored

.PARAMETER ExtraPass3Safe
Safe where reconcile account is stored

.PARAMETER DynamicProperties
Hashtable of name=value pairs

.PARAMETER sessionToken
Hashtable containing the session token returned from New-PASSession

.PARAMETER WebSession
WebRequestSession object returned from New-PASSession

.PARAMETER BaseURI
PVWA Web Address
Do not include "/PasswordVault/"

.EXAMPLE

.INPUTS
Session Token, WebSession & BaseURI can be piped by propertyname

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
        [string]$safe,

        [parameter(
            Mandatory=$true
        )]
        [string]$platformID,

        [parameter(
            Mandatory=$false
        )]
        [string]$address,

        [parameter(
            Mandatory=$false
        )]
        [string]$accountName,

        [parameter(
            Mandatory=$true
        )]
        [string]$password,

        [parameter(
            Mandatory=$false
        )]
        [string]$username,

        [parameter(
            Mandatory=$false,
            ParameterSetName="disableAutoMgmt"
        )]
        [boolean]$disableAutoMgmt,

        [parameter(
            Mandatory=$false,
            ParameterSetName="disableAutoMgmt"
        )]
        [string]$disableAutoMgmtReason,
        
        [parameter(
            Mandatory=$false
        )]
        [string]$groupName,

        [parameter(
            Mandatory=$false
        )]
        [string]$groupPlatformID,

        [parameter(
            Mandatory=$false
        )]
        [int]$Port,

        [parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ExtraPass1Name,

        [parameter(
            Mandatory=$false
        )]
        [string]$ExtraPass1Folder,

        [parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ExtraPass1Safe,

        [parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ExtraPass3Name,

        [parameter(
            Mandatory=$false
        )]
        [string]$ExtraPass3Folder,

        [parameter(
            Mandatory=$false
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ExtraPass3Safe,

        [parameter(
            Mandatory=$false
        )]
        [hashtable]$DynamicProperties,
          
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

    BEGIN{
        
        #The Add Account JSON object requires specific formatting.
        #Different parameters are contained within the JSON at different depths.
        #Progromatic processing is required to format the JSON as required.

        #baseparameters are contained in JSON object at the same depth
        $baseParameters = @("Safe","PlatformID","Address","AccountName","Password","Username",
            "DisableAutoMgmt","DisableAutoMgmtReason","GroupName","GroupPlatformID")
         
        #declare empty hashtable to hold "non-base" parameters        
        $properties=@{}

        #declare empty array to hold keys to remove from bound parameters
        $keysToRemove = @()

    }#begin

    PROCESS{

        #Create URL for Request
        $URI = "$baseURI/PasswordVault/WebServices/PIMServices.svc/Account"

        #Get all parameters that will be sent in the request
        $boundParameters = $PSBoundParameters | Get-PASParameters
        
        #Process for required formatting

        #Get "non-base" parameters
        $boundParameters.keys | Where{$baseParameters -notcontains $_} | foreach{
            
            #For all "non-base" parameters except "DynamicProperties" 
            if($_ -ne "DynamicProperties"){
                
                #Add key/Value to "properties" hashtable
                $properties[$_]=$boundParameters[$_]

            }

            Else{ #for DynamicProperties key=value pairs
                
                #Enumerate DynamicProperties object
                $boundParameters[$_].getenumerator() | foreach{
                    
                    #add key=value to "properties" hashtable
                    $properties[$_.name]=$_.value
                
                }
            }

            #add the "non-base" parameter key to array
            [array]$keysToRemove+=$_
        
        } 

        #Add "non-base" parameter hashtable as value of "properties" on boundparameters object
        $boundParameters["properties"] = @($properties.getenumerator() | foreach{$_})

        #Create body of request
        $body = @{

                    #account node does not contain non-base parameters
                    "account" = $boundParameters | Get-PASParameters -ParametersToRemove $keysToRemove

                    #ensure nodes at all required depths are included in the JSON object
                } | ConvertTo-Json -Depth 4
        
        #send request to PAS web service
        Invoke-PASRestMethod -Uri $URI -Method POST -Body $Body -Headers $sessionToken -WebSession $WebSession

    }#process

    END{}#end
}