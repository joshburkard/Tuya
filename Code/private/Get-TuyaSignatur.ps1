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
