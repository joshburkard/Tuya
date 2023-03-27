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