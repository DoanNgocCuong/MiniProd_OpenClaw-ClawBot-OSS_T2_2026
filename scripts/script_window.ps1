# ClawBot - Windows PowerShell script (Install / Add Telegram channel / Approve pairing)
# Usage:
#   .\script_window.ps1 Install
#   .\script_window.ps1 AddChannel
#   .\script_window.ps1 Approve -Code 483921
# Chạy trên Windows; openclaw chạy trong WSL2 (Ubuntu).

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Install', 'AddChannel', 'Approve')]
    [string]$Command,

    [Parameter(Mandatory = $false)]
    [string]$Code
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# Load .env (KEY=VALUE) from repo root or config/
function Load-Env {
    foreach ($path in @("$RepoRoot\.env", "$RepoRoot\config\.env")) {
        if (Test-Path $path) {
            Get-Content $path | ForEach-Object {
                if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                    [System.Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
                }
            }
            break
        }
    }
}

# Resolve openclaw: prefer PATH, fallback to WSL
function Get-OpenClawCmd {
    $exe = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($exe) { return 'native' }
    $wsl = Get-Command wsl -ErrorAction SilentlyContinue
    if ($wsl) { return 'wsl' }
    throw 'openclaw not found. Chạy Install trước, hoặc cài WSL + Ubuntu.'
}

switch ($Command) {
    'Install' {
        Write-Host 'Cài OpenClaw qua npm trong WSL...'
        try {
            wsl bash -c 'source ~/.nvm/nvm.sh && nvm use 22 && npm install -g openclaw'
        } catch {
            Write-Host 'WSL không khả dụng hoặc cài thất bại. Chạy thủ công trong WSL:'
            Write-Host '  source ~/.nvm/nvm.sh && nvm use 22 && npm install -g openclaw'
            Write-Host '  openclaw onboard'
            exit 1
        }
        Write-Host ''
        Write-Host 'Cài xong! Chạy onboarding trong WSL:'
        Write-Host '  wsl bash -c "source ~/.nvm/nvm.sh && nvm use 22 && openclaw onboard"'
        Write-Host ''
    }

    'AddChannel' {
        Load-Env
        $token = [System.Environment]::GetEnvironmentVariable('TELEGRAM_BOT_TOKEN', 'Process')
        if ([string]::IsNullOrWhiteSpace($token)) {
            Write-Error 'TELEGRAM_BOT_TOKEN chưa set. Đặt trong .env hoặc export trước.'
        }
        $cmd = Get-OpenClawCmd
        if ($cmd -eq 'wsl') {
            wsl openclaw channels add telegram --token $token
        } else {
            & openclaw channels add telegram --token $token
        }
    }

    'Approve' {
        if ([string]::IsNullOrWhiteSpace($Code)) {
            Write-Host 'Usage: .\script_window.ps1 Approve -Code 483921'
            exit 1
        }
        $cmd = Get-OpenClawCmd
        if ($cmd -eq 'wsl') {
            wsl openclaw pairing approve telegram $Code
        } else {
            & openclaw pairing approve telegram $Code
        }
    }
}
