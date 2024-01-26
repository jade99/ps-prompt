<#  Windows PowerShell 7 - Custom Prompt
    Author: Philipp '!jⱯde99_' Wurzer 
    
    Use with CaskaydiaCove NFM, Version 2111.001
#>

# -----===== Constants =====-----
$OutputEncoding = [System.Text.Encoding]::Unicode

$SYM_SEG1 = [char] 0xe0ba
$SYM_SEG2 = [char] 0xe0bc
$SYM_SEG3 = [char] 0xe0bb

$SYM_HOME = [char] 0xf015
$SYM_FOLDER = [char] 0xf07c
$SYM_SHARE = [char] 0xf98c
$SYM_CUBES = [char] 0xf1b3
$SYM_CERT = ([char] 0xdb84, [char] 0xdd87) -join ''
$SYM_WSMAN = [char] 0xeb23
$SYM_FUNC = ([char] 0xdb82, [char] 0xdc71) -join ''
$SYM_VAR = [char] 0xe691
$SYM_ENV = [char] 0xebb8
$SYM_AT = ([char] 0xdb80, [char] 0xdc65) -join ''

$SYM_CMD = [char] 0xf641
$SYM_BOLT = [char] 0xf0e7
$SYM_WIN = [char] 0xe70f

$SYM_GIT = [char] 0xf113
$SYM_PUSH = [char] 0xf40a
$SYM_PULL = [char] 0xf409
$SYM_FF = [char] 0xf102
$SYM_BRANCH = [char] 0xe725
$SYM_DETACH = [char] 0xf127
$SYM_LOCAL = [char] 0xf108

$UI = $Host.UI.RawUI
$CON_WIDTH = $UI.WindowSize.Width

$GIT_REPO = $(git rev-parse --is-inside-work-tree) 2>$null

$UI.BackgroundColor = 'Black'
$UI.ForegroundColor = 'Gray'

#Clear-Host

$RawPrompt = ''

function prompt_start {
    $Out = $SYM_SEG1
    $RawPrompt += $Out

    Write-Host -Object $Out -ForegroundColor DarkGray -BackgroundColor Black -NoNewline

    # -----===== Check if Administrator =====-----
    $CurrentPrincipal = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList @([System.Security.Principal.WindowsIdentity]::GetCurrent())
    if ($CurrentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $Out = " $SYM_BOLT"
        $RawPrompt += $Out

        Write-Host -Object $Out -ForegroundColor DarkYellow -BackgroundColor DarkGray -NoNewline
    }

    $Out = " $SYM_WIN $env:COMPUTERNAME "
    $RawPrompt += $Out
    
    Write-Host -Object $Out -ForegroundColor Cyan -BackgroundColor DarkGray -NoNewline
}

function prompt_pwd {
    $Out = $SYM_SEG1
    $RawPrompt += $Out

    Write-Host -Object $Out -ForegroundColor Red -BackgroundColor DarkGray -NoNewline

    $CurrentLocation = Get-Location
    $Location = ''

    $CurrentLeaf = $CurrentLocation
    if ($CurrentLocation.Path -ne "$($CurrentLocation.Drive.Name):\") {
        $CurrentLeaf = Split-Path -Path $CurrentLocation.Path -Leaf
    }

    $HomePattern = "^$([regex]::Escape($env:USERPROFILE))"
    $SharePattern = "^$([regex]::Escape('Microsoft.PowerShell.Core\FileSystem::'))"

    $ProviderSym = ''
    switch ($CurrentLocation.Provider.Name) {
        'FileSystem' {
            if ($CurrentLocation.Path -match $HomePattern) {
                $ProviderSym = $SYM_HOME
                $Location = $CurrentLocation.Path -replace $HomePattern,"$ProviderSym ~"

            } elseif ($CurrentLocation.Path -match $SharePattern) {
                $ProviderSym = $SYM_SHARE
                $Location = $CurrentLocation.Path -replace $SharePattern,"$ProviderSym "

            } else {
                $ProviderSym = $SYM_FOLDER
                $Location = "$ProviderSym $($CurrentLocation.Path)"

            }

            if ($GIT_REPO -eq 'true') {
                $Location = $Location.Replace($ProviderSym,$SYM_GIT)
            }
        }

        'Registry' {
            $ProviderSym = $SYM_CUBES
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'Certificate' {
            $ProviderSym = $SYM_CERT
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'WSMan' {
            $ProviderSym = $SYM_WSMAN
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'Function' {
            $ProviderSym = $SYM_FUNC
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'Variable' {
            $ProviderSym = $SYM_VAR
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'Environment' {
            $ProviderSym = $SYM_ENV
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        'Alias' {
            $ProviderSym = $SYM_AT
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }

        Default {
            $Location = "$ProviderSym $($CurrentLocation.Path)"
        }
    }

    if ($RawPrompt.Length + $Location.Length -gt $CON_WIDTH / 3) {
        $Location = "$ProviderSym $($CurrentLocation.Path -eq $env:USERPROFILE ? '~' : $CurrentLeaf)"
    }


    $Out = " $Location "
    $RawPrompt += $Out

    Write-Host -Object $Out -ForegroundColor Gray -BackgroundColor Red -NoNewline
    Write-Host -Object $SYM_SEG2 -ForegroundColor Red -BackgroundColor Black -NoNewline
}

function prompt_runtime {
    $Out = ''
    $ExecDuration = $(Get-History)[-1].Duration
    if ($ExecDuration.TotalSeconds -ge 100) {
        $Out = "$([Math]::Round($ExecDuration.TotalSeconds,0))s"
    } elseif ($ExecDuration.TotalSeconds -ge 1) {
        $Out = "$([Math]::Round($ExecDuration.TotalSeconds,1))s"
    } elseif ($ExecDuration.TotalMilliseconds -ge 100) {
        $Out = "$([Math]::Round($ExecDuration.TotalMilliseconds,0))ms"
    } else {
        $Out = "$([Math]::Round($ExecDuration.TotalMilliseconds,1))ms"
    }

    $UI.CursorPosition = New-Object -TypeName System.Management.Automation.Host.Coordinates -ArgumentList @($($UI.CursorPosition.X - ($Out.Length + 3)), $UI.CursorPosition.Y)

    if ($GIT_REPO -ne 'true') {
        Write-Host -Object $SYM_SEG1 -ForegroundColor Magenta -BackgroundColor Black -NoNewline
    }

    Write-Host -Object " $Out " -ForegroundColor Gray -BackgroundColor Magenta -NoNewline
    Write-Host -Object $SYM_SEG2 -ForegroundColor Magenta -BackgroundColor Black -NoNewline

    if ($GIT_REPO -eq 'true') {
        $UI.CursorPosition = New-Object -TypeName System.Management.Automation.Host.Coordinates -ArgumentList @($($UI.CursorPosition.X - ($Out.Length + 3)), $UI.CursorPosition.Y)
    }
}

function prompt_git {
    $Out = ''
    $Status = $(git status)
    
    $Head = $Status | Select-String -Pattern '^(On Branch|HEAD detached at)(.+)$'
    $Remote = $Status | Select-String -Pattern '^Your branch (is (?:up|ahead|behind)|and).*$'

    
    $Out_Head = "$($Head.Matches.Groups[2]) $SYM_SEG1"
    $Out_Status = ''

    $GIT_FG = 'DarkGray'
    $GIT_BG = 'Cyan'

    if ($Remote.Matches.Success -eq $true) {
        switch ($Remote.Matches.Groups[1].Value) {
            'is up' {
                $Out_Status += "-- --"
                break 
            }
            'is ahead' {
                $Ahead = $Remote.Matches.Groups[0].Value| Select-String -Pattern 'by (\d+) commits?'
                $Out_Status += "+$($Ahead.Matches.Groups[1]) $SYM_PUSH --"

                $GIT_BG = 'DarkGreen'
                $GIT_FG = 'Gray'
                break;
            }
            'is behind' {
                $Behind = $Remote.Matches.Groups[0].Value | Select-String -Pattern 'by (\d+) commits?(, .+)?'
                if ($Remote.Matches.Groups[2].Success -eq $False) {
                    $Out_Status += "--  $SYM_PULL -$($Behind.Matches.Groups[1])"
                } else {
                    $Out_Status += "-- $SYM_FF -$($Behind.Matches.Groups[1])"
                }

                $GIT_BG += 'Red'
                $GIT_FG += 'White'
                break;
            }
            'and' {
                $Diverge = $Status | Select-String -Pattern 'have (\d+) and (\d+) different commits'
                $Out_Status += "+$($Diverge.Matches.Groups[1]) $SYM_BRANCH -$($Diverge.Matches.Groups[2])"

                $GIT_BG = 'Yellow'
                $GIT_FG = 'Black'
                break;
            }
        }
    } elseif ($Head.Matches.Groups[1].Value -eq 'HEAD detached at') {
        $Out_Status += $SYM_DETACH
    } else {
        $Out_Status += $SYM_LOCAL
    }

    $Out = "$Out_Head $Out_Status"
    $UI.CursorPosition = New-Object -TypeName System.Management.Automation.Host.Coordinates -ArgumentList @($($UI.CursorPosition.X - ($Out.Length + 3)), $UI.CursorPosition.Y)

    Write-Host -Object $SYM_SEG1 -ForegroundColor $GIT_BG -BackgroundColor Black -NoNewline
    Write-Host -Object " $Out_Head" -ForegroundColor $GIT_FG -BackgroundColor $GIT_BG -NoNewline
    Write-Host -Object " $Out_Status " -ForegroundColor Black -BackgroundColor Gray -NoNewline
    Write-Host -Object "$SYM_SEG2 " -ForegroundColor Gray -BackgroundColor Magenta -NoNewline
}

function prompt {
    $CON_WIDTH = $UI.WindowSize.Width
    $GIT_REPO = $(git rev-parse --is-inside-work-tree) 2>$null

    prompt_start
    prompt_pwd

    $UI.CursorPosition = New-Object -TypeName System.Management.Automation.Host.Coordinates -ArgumentList @($($CON_WIDTH - 1), $UI.CursorPosition.Y)

    if ($(Get-History).Length -gt 0) {
        prompt_runtime
    }

    if ($GIT_REPO -eq 'true') {
        prompt_git
    }

    Write-Host -Object "`n$SYM_CMD" -ForegroundColor Gray -BackgroundColor Black -NoNewline
    return ' '
}
