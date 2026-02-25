# ClawBot - Windows PowerShell script (Install / Add Telegram channel / Approve pairing)
# Usage:
#   .\script_window.ps1 Install
#   .\script_window.ps1 AddChannel
#   .\script_window.ps1 Approve -Code 483921
# Chạy trên Windows; nếu dùng OpenClaw qua WSL2, các lệnh openclaw sẽ chạy trong WSL.

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
    throw 'openclaw not found. Install OpenClaw (run Install in this script) and ensure openclaw is in PATH or WSL.'
}

switch ($Command) {
    'Install' {
        Write-Host 'Installing OpenClaw (via WSL)...'
        try {
            wsl bash -c 'curl -fsSL https://openclaw.ai/install.sh | bash'
        } catch {
            Write-Host 'WSL not available or install failed. Run manually in WSL (Ubuntu):'
            Write-Host '  curl -fsSL https://openclaw.ai/install.sh | bash'
            Write-Host '  openclaw onboard'
            exit 1
        }
        Write-Host ''
        Write-Host 'Install done. Run the following and paste your OpenAI API key when prompted:'
        Write-Host '  wsl openclaw onboard'
        Write-Host ''
    }

    'AddChannel' {
        Load-Env
        $token = [System.Environment]::GetEnvironmentVariable('TELEGRAM_BOT_TOKEN', 'Process')
        if ([string]::IsNullOrWhiteSpace($token)) {
            Write-Error 'TELEGRAM_BOT_TOKEN not set. Set it in .env (repo root or config/) or in environment.'
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
            Write-Host 'Example: .\script_window.ps1 Approve -Code 483921'
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
