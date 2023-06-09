# Connect-Tuya

## SYNOPSIS

Connects to the Tuya API

## SYNTAX

```powershell
Connect-Tuya [-ClientID] <String> [-ClientSecret] <String> [[-Region] <String>] [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>]

[<CommonParameters>]
```

## DESCRIPTION

this function connects to the Tuya API and defines the needed variable for later use

## PARAMETERS

### -ClientID &lt;String&gt;

This parameter defines the ClientID to access the API

```
Required?                    true
Position?                    1
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -ClientSecret &lt;String&gt;

This parameter defines the ClientSecret to access the API

```
Required?                    true
Position?                    2
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Region &lt;String&gt;

tis parameter defines the API region

this string parameter is not mandatory, the default value is EU

```
Required?                    false
Position?                    3
Default value                EU
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Proxy &lt;String&gt;

```
Required?                    false
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -ProxyCredential &lt;PSCredential&gt;


```
Required?                    false
Position?                    5
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

## NOTES

```
Date, Author, Version, Notes
```

## EXAMPLES

### EXAMPLE 1

```powershell
Connect-Tuya -ClientID '1234567890abc' -ClientSecret 'ff12f3fba4567b123bfaffe45aff6789'
```


