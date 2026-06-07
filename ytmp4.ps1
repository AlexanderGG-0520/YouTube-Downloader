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

function Get-SafeFileName($Name) {
    $Safe = $Name -replace '[<>:"/\\|?*\x00-\x1F]', '_'
    $Safe = $Safe.Trim().TrimEnd(".")
    if ([string]::IsNullOrWhiteSpace($Safe)) {
        $Safe = "video"
    }
    if ($Safe.Length -gt 120) {
        $Safe = $Safe.Substring(0, 120).Trim().TrimEnd(".")
    }
    return $Safe
}

function Test-PathUnderBase($Path, $BasePath) {
    if ([string]::IsNullOrWhiteSpace($Path) -or [string]::IsNullOrWhiteSpace($BasePath)) {
        return $false
    }
    $FullPath = [System.IO.Path]::GetFullPath($Path)
    $FullBase = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    return $FullPath.StartsWith($FullBase + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Remove-SafeDirectory($Path, $BasePath) {
    if ((Test-PathUnderBase $Path $BasePath) -and (Test-Path -LiteralPath $Path)) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DownloadDir = Join-Path $ScriptDir "downloaded"
$TmpRoot = Join-Path $ScriptDir "tmp"
$RunId = Get-Date -Format "yyyyMMdd_HHmmss"
$TmpDir = Join-Path $TmpRoot $RunId

if ($args.Count -gt 0) {
    $Url = ($args -join " ").Trim()
} else {
    $Url = (Read-Host "動画URLを貼ってEnter").Trim()
}

if ([string]::IsNullOrWhiteSpace($Url)) {
    Fail "URLが入力されていません。"
}

$YtDlp = Get-RequiredCommand "yt-dlp"
$Ffmpeg = Get-RequiredCommand "ffmpeg"

New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null
New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

try {
    Write-Host "動画タイトルを取得しています..."
    $Title = & $YtDlp --no-playlist --get-title $Url 2>$null | Select-Object -First 1
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Title)) {
        Fail "動画タイトルを取得できませんでした。URLを確認してください。"
    }

    $SafeTitle = Get-SafeFileName $Title
    $OutputPath = Join-Path $DownloadDir ($SafeTitle + "_" + $RunId + ".mp4")
    $TempOutput = Join-Path $TmpDir "source.%(ext)s"

    Write-Host "一時フォルダにダウンロードしています..."
    & $YtDlp --no-playlist -f "bv*+ba/b" -o $TempOutput $Url
    if ($LASTEXITCODE -ne 0) {
        Fail "ダウンロードに失敗しました。"
    }

    $SourceFiles = Get-ChildItem -LiteralPath $TmpDir -File | Where-Object {
        $_.Extension -notin @(".part", ".ytdl", ".temp", ".tmp")
    } | Sort-Object LastWriteTime -Descending

    if (-not $SourceFiles -or $SourceFiles.Count -eq 0) {
        Fail "変換元ファイルが見つかりませんでした。"
    }

    $SourcePath = $SourceFiles[0].FullName

    Write-Host "MP4 + H.264 + AAC に変換しています..."
    & $Ffmpeg -y -i $SourcePath -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k -movflags +faststart $OutputPath
    if ($LASTEXITCODE -ne 0) {
        Fail "MP4への変換に失敗しました。"
    }

    Write-Host ""
    Write-Host "完了しました: $OutputPath" -ForegroundColor Green
} finally {
    Remove-SafeDirectory $TmpDir $ScriptDir
    if ((Test-PathUnderBase $TmpRoot $ScriptDir) -and (Test-Path -LiteralPath $TmpRoot)) {
        $Remaining = Get-ChildItem -LiteralPath $TmpRoot -Force -ErrorAction SilentlyContinue
        if (-not $Remaining) {
            Remove-Item -LiteralPath $TmpRoot -Force
        }
    }
}

Write-Host "Enter キーを押すと終了します。"
Read-Host | Out-Null
