$ErrorActionPreference = "Stop"

if ($PSScriptRoot) {
    $RepoRoot = $PSScriptRoot
} else {
    $RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Pause-Window {
    Write-Host ""
    Write-Host "何かキーを押して閉じてください..."
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        Read-Host "Enterキーを押して閉じてください"
    }
}

try {
    Write-Host "最新版への更新を開始します。"
    Set-Location -Path $RepoRoot

    Write-Host "現在のフォルダ: $(Get-Location)"

    $GitCommand = Get-Command git -ErrorAction SilentlyContinue
    if (-not $GitCommand) {
        Write-Host "エラー: git が見つかりません。"
        Write-Host "Gitをインストールしてから、もう一度 update.bat を実行してください。"
        Write-Host "Chocolateyを使う場合の例: choco install git -y"
        exit 1
    }

    if (-not (Test-Path -Path (Join-Path $RepoRoot ".git") -PathType Container)) {
        Write-Host "エラー: このフォルダはGitリポジトリではありません。"
        Write-Host "GitHubから取得したリポジトリのフォルダ内で update.bat を実行してください。"
        exit 1
    }

    Write-Host ""
    Write-Host "git pull origin main を実行します。"
    & git pull origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "更新が完了しました。"
    } else {
        Write-Host ""
        Write-Host "更新に失敗しました。"
        Write-Host "上に表示されたGitのエラー内容を確認してください。"
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "更新に失敗しました。"
    Write-Host $_.Exception.Message
    exit 1
} finally {
    Pause-Window
}
