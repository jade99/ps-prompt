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
   
    $return = "$symbol "

    if ($format -ne "raw") {
        Write-Host "$symbol " -NoNewline -ForegroundColor $THEME_START[0] -BackgroundColor $THEME_START[1]
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
