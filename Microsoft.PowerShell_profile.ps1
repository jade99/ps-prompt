#author Philipp Wurzer

chcp 65001 #UTF-8 für Legacy Unterstüzung
$OutputEncoding = [System.Text.Encoding]::Unicode
clear

<# Install an powerline font from https://github.com/powerline/fonts
   or patch an existing font to include powerline characters using:
   https://github.com/powerline/fontpatcher (python required) #>
$flowChar = ""

<# recommended color pallet:
   Color:       R   B   G   Default
   
   Black:       12  12  12  Background
   DarkBlue:    0   55  218
   DarkGreen:   19  161 14
   DarkCyan:    58  150 221
   DarkRed:     197 15  31
   DarkMagenta: 138 28  152
   DarkYellow:  193 156 0
   Gray:        204 204 204 Foreground
   DarkGray:    118 118 118 Highlight Foreground
   Blue:        59  120 255
   Green:       22  198 12
   Cyan:        97  214 214
   Red:         231 72  68
   Magenta:     180 0   158
   Yellow:      249 247 165
   White:       242 242 242 Highlight Background #>

#Theme configuration: Foreground, Background
$THEME_START = @("Black", "Yellow")
$THEME_USER = @("Black", "DarkYellow")


$THEME_WORKDIR_FILE = @("White", "DarkGreen")
$THEME_WORKDIR_REG = @("Black", "DarkCyan")
$THEME_WORKDIR_CERT = @("White", "DarkMagenta")
$THEME_WORKDIR_ALIAS = @("Black", "Gray")

$THEME_WORKDIR = $THEME_WORKDIR_FILE #DO NOT CHANGE


$TERM_BACKGROUND = (Get-Host).UI.RawUI.BackgroundColor


function build-prompt_start ($format) {
    $symbol = "PS"
    $exitCode = $LASTEXITCODE
   
    $return = "$symbol "

    if ($format -ne "raw") {
        Write-Host "$symbol " -NoNewline -ForegroundColor $THEME_START[0] -BackgroundColor $THEME_START[1]
    }

    if ($exitCode -ne 0) {
        
        $return += "$return "

        if ($format -ne "raw") {
            Write-Host "$exitCode " -NoNewline -ForegroundColor $THEME_START[0] -BackgroundColor $THEME_START[1]
        }

    }

    $return += "$flowChar "

    if ($format -ne "raw") {
        Write-Host "$flowChar " -NoNewline -ForegroundColor $THEME_START[1] -BackgroundColor $THEME_USER[1]
    }
    
    return $return
}



function build-prompt_user ($format) {
    $user = $env:USERNAME
    $domain = $env:USERDOMAIN
    $computername = $env:COMPUTERNAME

    $return = ""

    if ("$domain" -ne "$computername" -and $format -ne "short") {
        $return += "\\$domain\"

        if ($format -ne "raw") {
            Write-Host "\\$domain\" -NoNewline -ForegroundColor $THEME_USER[0] -BackgroundColor $THEME_USER[1]
        }
    }

    $return += "$user@$computername "

        if ($format -ne "raw") {
            Write-Host "$user" -NoNewline -ForegroundColor $THEME_USER[0] -BackgroundColor $THEME_USER[1]
            if ($format -eq "full") {
                Write-Host "@$computername " -NoNewline -ForegroundColor $THEME_USER[0] -BackgroundColor $THEME_USER[1]
            }
        }

    return $return
}



function build-prompt_workdir ($format) {
    $pwd = Get-Location
    $provider = (Get-Location).Provider.Name

    if ("$provider" -eq "Registry") {
        $THEME_WORKDIR = $THEME_WORKDIR_REG
    } elseif ("$provider" -eq "Certificate") {
        $THEME_WORKDIR = $THEME_WORKDIR_CERT
    } elseif ("$provider" -eq "Alias") {
        $THEME_WORKDIR = $THEME_WORKDIR_ALIAS
    }

    $return += "$flowChar "
    if ($format -ne "raw") {
        Write-Host "$flowChar " -NoNewline -ForegroundColor $THEME_USER[1] -BackgroundColor $THEME_WORKDIR[1]
    }


    $return = ""

    if ("$pwd" -eq "$env:USERPROFILE") {
        $return += "~ "
        
        if ($format -ne "raw") {
            Write-Host "~ " -NoNewline -ForegroundColor $THEME_WORKDIR[0] -BackgroundColor $THEME_WORKDIR[1]
        }
    } else {
        $pwdShortShare = "$pwd".Replace('Microsoft.PowerShell.Core\FileSystem::','')
        $return += "$pwdShortShare "

        if ($format -ne "raw") {
            if ($format -eq "full" -or $pwdShortShare -like '*$' -or $pwdShortShare -like 'Cert:\' -or $pwdShortShare -like 'Alias:\') {
                Write-Host "$pwdShortShare " -NoNewline -ForegroundColor $THEME_WORKDIR[0] -BackgroundColor $THEME_WORKDIR[1]
            } else {
                Write-Host "$($pwd | Split-Path -Leaf) " -NoNewline -ForegroundColor $THEME_WORKDIR[0] -BackgroundColor $THEME_WORKDIR[1]
            }
        }
    }

    $return += "$flowChar"

    if ($format -ne "raw") {
        Write-Host "$flowChar" -NoNewline -ForegroundColor $THEME_WORKDIR[1] -BackgroundColor $TERM_BACKGROUND
    }
    
    return $return
 }



function build-prompt ($format) {
    $return = build-prompt_start $format
    $return += build-prompt_user $format
	$return += build-prompt_workdir $format

    if ($format -eq "raw") {
        return "$return "
    }
}


function prompt {
    $TERM_WIDTH = (Get-Host).UI.RawUI.WindowSize.Width
    $TERM_BACKGROUND = (Get-Host).UI.RawUI.BackgroundColor

    $prompt = build-prompt "raw"
    if ("$prompt".Length -lt $TERM_WIDTH/3) {
        "$(build-prompt `"full`") "
    } else {
        "$(build-prompt `"short`") "
    }
}
# SIG # Begin signature block
# MIIFcQYJKoZIhvcNAQcCoIIFYjCCBV4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtZXXH6ArmRUE17/ct7LmW5q5
# yGygggMSMIIDDjCCAfagAwIBAgIQLtQJEVM1nr9LdIqLeRCPBDANBgkqhkiG9w0B
# AQsFADAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwHhcNMTkwMjI4MDgyNTMyWhcNMjAw
# MjI4MDg0NTMyWjAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQDJPoMBS9CJLmxMuA2suYaoX1/yXgQLKUxidHxybOrb
# GqmpO0IKODL5pG0xwTPDsf7xe3Jr9njtszFP7i+X4xLJtpJrxJnduT5Qh+v6TOac
# Jchspj2iibsk4Q1j/jo8c37VkkyL3pVvv4gA3FympWRUGP3rBNq+tuYEZXIKmmWb
# Y0+Fltpm6pJRGjL62it+/5e8TaUrAmEeZaZdCa/Jz6axBa84agGbyYNnfxua/lqQ
# 7NOZoGTCzSLOfztxEgcB1EanN6j10S4tLewl9fjq/0gaQCXeAElUkY368LO9CX0e
# 2Ktk8xDPba4Eew+Ajy5V7YNlvkdp1L3UaLD8rxGtUkZVAgMBAAGjXDBaMA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAUBgNVHREEDTALgglsb2Nh
# bGhvc3QwHQYDVR0OBBYEFPhdCcjNJdfTdTPYvkXrtxpc2MSMMA0GCSqGSIb3DQEB
# CwUAA4IBAQDGWDGWoXbCx62Wsk80LIEQMR25fKTLN1bFfAUPIm9rDaHR3zzt2sJ3
# p73rlo9qvTNgjVonmZmMzeRJqjaUea1qKjZ3DMZqbJFvrm2B0savkD8e0oEmsabE
# ITFGCP50Rumhemv9AMMGbzF6R0TVALaIte8ykZ/nJsCEMNOAN4pp2t75GpHv/XkB
# CKVQDV5FbtqXjymW/NV3rF8mlXw10WdHZHaPExCPGxaNKo7kJ3ucF4yCcQ/Bn+6Y
# AbavTGOJbYFM7pC2nvJ8ZYzDfpyL2ZAY3NGFGbCI9dgSoFebiET0pR4vJ5Blqi/p
# HEqG0w07U4OreM19FtsTt0s+EUc7hreNMYIByTCCAcUCAQEwKDAUMRIwEAYDVQQD
# DAlsb2NhbGhvc3QCEC7UCRFTNZ6/S3SKi3kQjwQwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBW/
# SEi3srQ3vDjRzOwRS7iR+y4aMA0GCSqGSIb3DQEBAQUABIIBAJkOWTs5IU3LwPaH
# NvB6mzwOX2DeWkY1YwwVq5JLxaC32SBim8GW+qw7JCEL1E9rwOglpKSyZNw3walY
# /H/Z4fKLkpT7WbcBsrtleo9zW+bMebL4TxIek0UjUEoTS3AfgjDp/lpuSCjvoozd
# V1upbBpuH0035KZgkCCwxyRZESqg3LiWtKKmZ+6lc3KyxI1hNaErq8O7drsUXRYx
# rSknTYJ1y27zJyzSvUOyJLKaad1qDbZy1VN+e0sCEUh3pJkJiPc2UqBAdRzWiCGe
# 7rK30QOvFztFV8Hudz/n80OzhmEqvBXuOuLOB0Qt5MzDj7DJDgfSjepbbaPElpd0
# rZFbBrc=
# SIG # End signature block
