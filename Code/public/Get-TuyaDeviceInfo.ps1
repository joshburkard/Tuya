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