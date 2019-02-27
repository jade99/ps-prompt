chcp 65001
clear


$flowChar = ""



function build-prompt_start {
    $symbol = "PS"
    $return = $LASTEXITCODE

    Write-Host "$symbol " -NoNewline -ForegroundColor DarkMagenta -BackgroundColor DarkYellow

    if ($return -ne 0) {
        Write-Host "$return " -NoNewline -ForegroundColor Red -BackgroundColor DarkYellow
    }

    Write-Host "$flowChar " -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkRed
}



function build-prompt_user {
    $user = $env:USERNAME
    $domain = $env:USERDOMAIN
    $localmachine = $env:COMPUTERNAME

    if ("$domain" -ne "" ) {
        Write-Host "\\$domain\" -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkRed
    }

    Write-Host "$user@$localmachine " -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkRed
    Write-Host "$flowChar " -NoNewline -ForegroundColor DarkRed -BackgroundColor DarkGreen

}



function build-prompt_workdir {
    $pwd = $(Get-Location)

    if ("$pwd" -eq "$env:USERPROFILE") {
        Write-Host "~ " -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkGreen
    } else {
        Write-Host "$pwd " -NoNewline -ForegroundColor DarkYellow -BackgroundColor DarkGreen
    }

    Write-Host "$flowChar" -NoNewline -ForegroundColor DarkGreen -BackgroundColor DarkMagenta
}



function build-prompt {
    Write-Host "$(build-prompt_start)" -NoNewline
	Write-Host "$(build-prompt_user)" -NoNewline
	Write-Host "$(build-prompt_workdir)" -NoNewline
}


function prompt {
    return "$(build-prompt) "
}