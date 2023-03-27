<#
    Generated at 03/26/2023 13:36:16 by Josh Burkard
#>
#region namespace Tuya
function Connect-Tuya {
    <#
        .SYNOPSIS
            Connects to the Tuya API

        .DESCRIPTION
            this function connects to the Tuya API and defines the needed variable for later use

        .PARAMETER ClientID
            This parameter defines the ClientID to access the API

        .PARAMETER ClientSecret
            This parameter defines the ClientSecret to access the API

        .PARAMETER Region
            tis parameter defines the API region

            this string parameter is not mandatory, the default value is EU

        .EXAMPLE
            Connect-Tuya -ClientID '1234567890abc' -ClientSecret 'ff12f3fba4567b123bfaffe45aff6789'

        .NOTES
            Date, Author, Version, Notes

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ClientID
        ,
        [Parameter(Mandatory=$true)]
        [string]$ClientSecret
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet('EU', 'China', 'WesternAmerica', 'EasternAmerica', 'WesternEurope', 'India' )]
        [string]$Region = 'EU'
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
    )
    try {
        switch ( $Region ) {
            'China' {
                $BaseURI = 'https://openapi.tuyacn.com'
            }
            'EU' {
                $BaseURI = 'https://openapi.tuyaeu.com'
            }
            'WesternAmerica' {
                $BaseURI = 'https://openapi.tuyaus.com'
            }
            'EasternAmerica' {
                $BaseURI = 'https://openapi-ueaz.tuyaus.com'
            }
            'WesternEurope' {
                $BaseURI = 'https://openapi-weaz.tuyaeu.com'
            }
            'India' {
                $BaseURI = 'https://openapi.tuyain.com'
            }
        }

        if ( Get-Variable -Name TuyaConfig -Scope Script -ValueOnly -ErrorAction SilentlyContinue ) {
            Remove-Variable -Name TuyaConfig -Scope Script
        }

        $nonce = ( New-Guid ).Guid
        $nonce = ''

        $InvokeParams = @{
            ClientID     = $ClientID
            ClientSecret = $ClientSecret
            URI          = "${BaseURI}/v1.0/token?grant_type=1"
            nonce        = $nonce
        }
        if ( [boolean]$Proxy ) {
            $InvokeParams.Add( 'Proxy', $TuyaConfig.Proxy )
        }
        if ( [boolean]$ProxyCredential ) {
            $InvokeParams.Add( 'ProxyCredential', $TuyaConfig.ProxyCredential )
        }

        $res = Invoke-TuyaRequest @InvokeParams

        if ( $res.success ) {
            if ( Get-Variable -Name TuyaConfig -ErrorAction SilentlyContinue ) {
                Remove-Variable -Name TuyaConfig -Scope Script
            }

            $Config = @{
                AccessToken  = $res.result.access_token
                ExpireTime   = $res.result.expire_time
                RefreshToken = $res.result.refresh_token
                uid          = $res.result.uid
                Region       = $Region
                ClientID     = $ClientID
                ClientSecret = $ClientSecret
                BaseURI      = $BaseURI
                nonce        = $nonce
            }
            if ( [boolean]$Proxy ) {
                $Config.Add( 'Proxy', $Proxy )
            }
            if ( [boolean]$ProxyCredential ) {
                $Config.Add( 'ProxyCredential', $ProxyCredential )
            }

            New-Variable -Name TuyaConfig -Value $Config -Scope Script
        } else {
            throw $res
        }
    } catch {
        throw "couldn't connect to Tuya API"
    }
    return $ret
}
function Get-TuyaDeviceCategory {
    <#
        .EXAMPLE
            Get-TuyaDeviceCategory
    #>
    [OutputType("System.Array")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        [string]$Code
        ,
        [Parameter(Mandatory=$false)]
        [string]$Name
    )
    try {
        <#
        $TuyaConfig = Get-Variable -Name TuyaConfig -Scope Script -ValueOnly -ErrorAction SilentlyContinue
        $InvokeParams = @{
            URI          = "/v1.0/iot-03/device-categories"
            ClientID     = $TuyaConfig.ClientID
            ClientSecret = $TuyaConfig.ClientSecret
            nonce        = $TuyaConfig.nonce
            AccessToken  = $TuyaConfig.AccessToken
        }
        if ( [boolean]$TuyaConfig.Proxy ) {
            $InvokeParams.Add( 'Proxy', $TuyaConfig.Proxy )
        }
        if ( [boolean]$TuyaConfig.ProxyCredential ) {
            $InvokeParams.Add( 'ProxyCredential', $TuyaConfig.ProxyCredential )
        }
        #>
        $res = Invoke-TuyaRequest -URI "/v1.0/iot-03/device-categories"

        if ( $res.success ) {
            $Categories = ( $res.result | Sort-Object Code )
            if ( [boolean]$Code ) {
                $Categories = $Categories | Where-Object { $_.Code -match $Code }
            }
            if ( [boolean]$Name ) {
                $Categories = $Categories | Where-Object { $_.Name -match $Name }
            }
            return $Categories
        } else {
            throw 'couldn''t get device datas'
        }

        if ( -not [boolean]$TuyaConfig ) {
            throw 'you have to use first the ''Connect-Tuya'' cmdlet'
        }
    } catch {
        throw 'couldn''t get device status'
    }
}
function Get-TuyaDeviceInfo {
    <#
        .EXAMPLE
            Get-TuyaDeviceInfo -DeviceID 01234567a909b87c6d5e
    #>
    [OutputType("HashTable")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$DeviceID
    )
    try {
        $res = Invoke-TuyaRequest -URI "/v1.0/devices/${DeviceID}"

        if ( $res.success ) {
            return $res.result
        } else {
            throw 'couldn''t get device datas'
        }

        if ( -not [boolean]$TuyaConfig ) {
            throw 'you have to use first the ''Connect-Tuya'' cmdlet'
        }
    } catch {
        throw 'couldn''t get device status'
    }
}
function Get-TuyaDeviceStatus {
    <#
        .EXAMPLE
            Get-TuyaDeviceStatus -DeviceID 01234567a909b87c6d5e
    #>
    [OutputType("HashTable")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$DeviceID
    )
    try {
        $res = Invoke-TuyaRequest -URI "/v1.0/devices/${DeviceID}"

        if ( $res.success ) {
            $ret = @{}
            $res.result.status | ForEach-Object {
                $ret.Add( $_.code.ToString(), $_.value )
            }
            return $ret
        } else {
            throw 'couldn''t get device datas'
        }

        if ( -not [boolean]$TuyaConfig ) {
            throw 'you have to use first the ''Connect-Tuya'' cmdlet'
        }
    } catch {
        throw 'couldn''t get device status'
    }
}
function Get-TuyaSignatur {
    <#
        .SYNOPSIS
            this private function calculates the signatur for the API call

        .DESCRIPTION
            this private function calculates the signatur for the API call

        .PARAMETER AccessToken
            the access token for an already pre authenticated session

            this string parameter is not mandatory

        .PARAMETER Body
            the body of the request

            this string parameter is not mandatory. but if the request contains a body, then the body parameter has to be used, otherwise the signature will be wrong.

        .PARAMETER ClientID
            the client ID to logon

            this value can be retrieved trough the Tuya IOT platform
            https://iot.tuya.com/cloud/ --> your project --> details --> Overview --> Access ID / Client ID

            this string parameter is mandatory

        .PARAMETER ClientSecret
            the client secret to logon

            this value can be retrieved trough the Tuya IOT platform
            https://iot.tuya.com/cloud/ --> your project --> details --> Overview --> Access Secret / Client Secret

            this string parameter is mandatory

        .PARAMETER CurrentTime
            the current time stamp in unix format

            this INT64 parameter is mandatory

        .PARAMETER nonce
            a unique id to separate sessions

            this string parameter is not mandatory

        .PARAMETER URI
            the URI to be requested

        .EXAMPLE
            $CurrentTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
            $nonce = ( New-Guid ).Guid

            $sign = Get-TuyaSign -ClientID $ClientID -AccessToken $AccessToken -CurrentTime $CurrentTime -nonce $nonce -ClientSecret $ClientSecret -Uri $URI

        .NOTES
            Date, Author, Version, Notes
            17.03.2023, Josh Burkard, 0.0.00001, initial creation
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ClientID
        ,
        [Parameter(Mandatory=$false)]
        [string]$AccessToken
        ,
        [Parameter(Mandatory=$true)]
        [int64]$CurrentTime
        ,
        [Parameter(Mandatory=$false)]
        [string]$nonce
        ,
        [Parameter(Mandatory=$true)]
        [string]$ClientSecret
        ,
        [Parameter(Mandatory=$false)]
        [string]$Body = ''
        ,
        [Parameter(Mandatory=$false)]
        [hashtable]$headers = $null
        ,
        [Parameter(Mandatory=$true)]
        $URI

    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        #region string to sign
            $URIPart = '/' + $URI.Split('/',4)[3]
            if ( [boolean]$headers ) {
                $headersStr = ( $headers.Keys | ForEach-Object { $_ + ":" + $headers."$( $_ )" } ) -join '`n'
            } else {
                $headersStr = ""
            }

            $sha = New-Object System.Security.Cryptography.SHA256Managed
            $shaHash = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes( $Body ) )
            $BodyString = [System.BitConverter]::ToString( $shaHash ).Replace('-','').ToLower()
            $stringToSign = "GET`n${BodyString}`n${headersStr}`n${URIPart}"
        #endregion string to sign

        #region create signature
            $signText = $ClientID + $AccessToken + $CurrentTime.ToString() + $nonce + $stringToSign
            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.key = [Text.Encoding]::UTF8.GetBytes( $ClientSecret )
            $hash = $hmacsha.ComputeHash( [Text.Encoding]::UTF8.GetBytes( $signText ) )
            $sign = [System.BitConverter]::ToString($hash).Replace('-','').ToUpper()
        #endregion create signature

        return $sign
    }
    catch {
        throw "couldn't calculate Tuya API Signature"
    }
}
function Invoke-TuyaRequest {
    <#
        .SYNOPSIS
            this function sends a request to the Tuya API

        .DESCRIPTION
            this function sends a request to the Tuya API

        .PARAMETER AccessToken
            the access token for an already pre authenticated session

            this string parameter is not mandatory

        .PARAMETER ClientID
            the client ID to logon

            this value can be retrieved trough the Tuya IOT platform
            https://iot.tuya.com/cloud/ --> your project --> details --> Overview --> Access ID / Client ID

            this string parameter is not mandatory

        .PARAMETER ClientSecret
            the client secret to logon

            this value can be retrieved trough the Tuya IOT platform
            https://iot.tuya.com/cloud/ --> your project --> details --> Overview --> Access Secret / Client Secret

            this string parameter is not mandatory

        .PARAMETER Headers
            the http headers to submit

        .PARAMETER nonce
            a unique id to separate sessions

            this string parameter is not mandatory

        .PARAMETER URI
            the URI to be requested

        .PARAMETER Proxy
            the Proxy server

            this string parameter is not mandatory

        .PARAMETER ProxyCredential
            the Credentials for the Proxy server

            this Credential parameter is not mandatory

        .EXAMPLE
            Invoke-TuyaRequest -URI "/v1.0/devices/${DeviceID}"

        .EXAMPLE
            Invoke-TuyaRequest -URI "/v1.0/devices/${DeviceID}"

        .NOTES
            Date, Author, Version, Notes
            17.03.2023, Josh Burkard, 0.0.00001, initial creation
        #>
    Param (
        [Parameter(Mandatory=$false)]
        [string]$AccessToken
        ,
        [Parameter(Mandatory=$false)]
        [string]$ClientID
        ,
        [Parameter(Mandatory=$false)]
        [string]$ClientSecret
        ,
        [Parameter(Mandatory=$false)]
        $Headers
        ,
        [Parameter(Mandatory=$false)]
        [string]$nonce = ''
        ,
        [Parameter(Mandatory=$true)]
        [string]$URI
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
    )

    $TuyaConfig = Get-Variable -Name TuyaConfig -Scope Script -ValueOnly -ErrorAction SilentlyContinue

    if ( [boolean]$TuyaConfig ) {
        if ( $URI -notmatch 'http' ) {
            $URI = $TuyaConfig.BaseURI + $URI
        }

        $ClientID     = $TuyaConfig.ClientID
        $ClientSecret = $TuyaConfig.ClientSecret
        $nonce        = $TuyaConfig.nonce
        $AccessToken  = $TuyaConfig.AccessToken
        if ( [boolean]$TuyaConfig.Proxy ) {
            $Proxy = $TuyaConfig.Proxy
        }
        if ( [boolean]$TuyaConfig.ProxyCredential ) {
            $ProxyCredential = $TuyaConfig.ProxyCredential
        }
    }

    if ( ( -not $ClientID ) -or ( -not $ClientSecret ) ) {
        throw "please use first the cmdlet 'Connect-Tuya'"
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $CurrentTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

    # $stringToSign = Get-TuyaStringToSign -URI $URI
    $sign = Get-TuyaSignatur -ClientID $ClientID -AccessToken $AccessToken -CurrentTime $CurrentTime -nonce $nonce -ClientSecret $ClientSecret -URI $URI

    $Headers = @{
        sign_method = 'HMAC-SHA256'
        client_id = $ClientID
        t = $CurrentTime.ToString()
        # nonce = '' # $nonce
        sign = $sign
        access_token = $AccessToken
    }
    if ( [boolean]$nonce ) {
        $Headers.Add( 'nonce', $nonce )
    }

    $InvokeParams = @{
        Uri = $URI
        Method = 'GET'
        Headers = $Headers
        ContentType = "application/json"
    }
    if ( [boolean]$Proxy ) {
        $InvokeParams.Add('Proxy', $Proxy )
        if ( [boolean]$ProxyCredential ) {
            $InvokeParams.Add('ProxyCredential', $ProxyCredential )
        }
    } else {
        $TempProxy = new-object System.Net.WebProxy
        [System.Net.WebRequest]::DefaultWebProxy = $TempProxy
    }

    $response = Invoke-RestMethod @InvokeParams
    $response
}


#endregion
