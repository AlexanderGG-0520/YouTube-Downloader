$ErrorActionPreference = "Stop"

function Fail($Message) {
    Write-Host ""
    Write-Host "エラー: $Message" -ForegroundColor Red
    Write-Host "Enter キーを押すと終了します。"
    Read-Host | Out-Null
    exit 1
}

function Get-RequiredCommand($Name) {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $Command) {
        Fail "$Name が見つかりません。Chocolatey でインストールし、PowerShell または CMD を開き直してください。"
    }
    return $Command.Source
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DownloadDir = Join-Path $ScriptDir "downloaded"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if ($args.Count -gt 0) {
    $Url = ($args -join " ").Trim()
} else {
    $Url = (Read-Host "動画URLを貼ってEnter").Trim()
}

if ([string]::IsNullOrWhiteSpace($Url)) {
    Fail "URLが入力されていません。"
}

$YtDlp = Get-RequiredCommand "yt-dlp"
$null = Get-RequiredCommand "ffmpeg"

New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

$OutputTemplate = Join-Path $DownloadDir ("%(title)s_" + $Timestamp + ".%(ext)s")

Write-Host "音声をMP3として保存しています..."
& $YtDlp --no-playlist -x --audio-format mp3 --audio-quality 0 -o $OutputTemplate $Url
if ($LASTEXITCODE -ne 0) {
    Fail "MP3保存に失敗しました。URLやネットワーク接続を確認してください。"
}

Write-Host ""
Write-Host "完了しました。保存先: $DownloadDir" -ForegroundColor Green
Write-Host "Enter キーを押すと終了します。"
Read-Host | Out-Null
