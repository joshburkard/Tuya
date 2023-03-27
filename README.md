# Tuya

## Table of Contents

- [Table of Contents](#table-of-contents)
- [General](#general)
- [Requirements](#requirements)
- [Usage](#usage)
- [Cmdlets](#cmdlets)

## General

This module allows to connect to the Tuya IOT API and request datas over a device

## Requirements

this requirements are needed to use this module

- Powershell 5.1, 7.3 (not tested with 7.1, 7.2)
- a Tuya Device
- an account on [https://iot.tuya.com](https://iot.tuya.com)
- a Tuya My Cloud project --> this generate an Client ID / Access ID and a Client Secret & Access Secret
- the Device ID

## Usage

```PowerShell
$ClientID = 'your Access / Client ID'
$ClientSecret = 'your Access / Client Secret'
$DeviceID = '01234567a909b87c6d5e'

Connect-Tuya -ClientID $ClientID -ClientSecret $ClientSecret -Region EU

Get-TuyaDeviceInfo -DeviceID $DeviceID
Get-TuyaDeviceStatus -DeviceID $DeviceID

Get-TuyaDeviceCategory -Name 'Gas'
Get-TuyaDeviceCategory -Code 'rq'
```

## CmdLets

- [Connect-Tuya](Help/Connect-Tuya.md)
- [Get-TuyaDeviceCategory](Help/CGet-TuyaDeviceCategory.md)
- [Get-TuyaDeviceInfo](Help/Get-TuyaDeviceInfo.md)
- [Get-TuyaDeviceStatus](Help/Get-TuyaDeviceStatus.md)
