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