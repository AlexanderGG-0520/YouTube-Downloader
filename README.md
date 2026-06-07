# Windows yt-dlp Helper

YouTube などの URL を貼り付けるだけで、動画を MP4、音声を MP3 として保存する Windows 用の補助ツールです。

保存先は、必ずこのツールと同じフォルダ内の `downloaded` フォルダです。

## できること

- `ytmp4.bat` で MP4 として保存
- `ytmp3.bat` で MP3 として保存
- 保存したファイルを `downloaded` フォルダにまとめる

## 事前準備

管理者 PowerShell を開き、Chocolatey で `yt-dlp` と `ffmpeg` をインストールします。

```powershell
choco install yt-dlp ffmpeg -y
```

インストール後、PowerShell または CMD を開き直してください。

確認コマンド:

```cmd
yt-dlp --version
ffmpeg -version
where.exe yt-dlp
where.exe ffmpeg
```

通常、Chocolatey の実行ファイルは `C:\ProgramData\chocolatey\bin` から見つかります。

## 使い方

MP4 で保存する場合:

1. `ytmp4.bat` をダブルクリックします。
2. 「動画URLを貼ってEnter」と表示されたら URL を貼り付けます。
3. Enter を押します。
4. `downloaded` フォルダを確認します。

MP3 で保存する場合も同じ手順で、`ytmp3.bat` をダブルクリックしてください。

## よくあるトラブル

### yt-dlp が見つからない

`yt-dlp` がインストールされていないか、PATH が反映されていません。

```powershell
choco install yt-dlp -y
```

インストール後、PowerShell または CMD を開き直してから、次を確認してください。

```cmd
where.exe yt-dlp
yt-dlp --version
```

### ffmpeg が見つからない

`ffmpeg` がインストールされていないか、PATH が反映されていません。

```powershell
choco install ffmpeg -y
```

インストール後、PowerShell または CMD を開き直してから、次を確認してください。

```cmd
where.exe ffmpeg
ffmpeg -version
```

### PowerShell が一瞬で閉じる

`ytmp4.ps1` または `ytmp3.ps1` を右クリックして「PowerShell で実行」するか、CMD から `.bat` を実行するとエラー内容を確認しやすくなります。

```cmd
ytmp4.bat
```

### bat の先頭に変な文字が出る

`.bat` が BOM 付き UTF-8 で保存されている可能性があります。

このリポジトリの `.bat` は BOM なし、かつ日本語コメントなしで保存しています。編集する場合は BOM なしで保存してください。

### MP4 なのに音が出ない

MP4 コンテナに Opus 音声が入っていると、Windows 標準再生や iPhone で問題になることがあります。

このツールの `ytmp4.ps1` は、最終出力を MP4 + H.264 + AAC に変換します。

## MP4 + Opus 問題について

`yt-dlp` でそのまま MP4 を作ると、環境や元動画によっては MP4 + Opus になることがあります。

Windows 標準再生や iPhone では MP4 + Opus が正しく再生できないことがあるため、このツールでは一度 `tmp` フォルダにダウンロードした後、`ffmpeg` で以下の形式に変換します。

- 動画: H.264
- 音声: AAC
- コンテナ: MP4

## 注意

権利者の許可がある動画、自分が保存してよい動画、利用規約上問題ない動画だけに使ってください。

