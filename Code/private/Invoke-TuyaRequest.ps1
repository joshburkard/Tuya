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


