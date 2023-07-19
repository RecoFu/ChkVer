param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$isoFilePath
)

# 將 ISO 檔掛載到一個可用的磁碟機
$mountResult = Mount-DiskImage $isoFilePath -PassThru
$mountedDrive = ($mountResult | Get-Volume).DriveLetter

# 使用 DISM 獲取 Windows 圖像的詳細資訊
$WinImages = Get-WindowsImage -ImagePath "$mountedDrive\sources\install.wim"

# 創建一個陣列來保存所有 Windows 圖像的資訊
$Report = @()

# 迴圈處理每個 Windows 圖像
foreach ($WinImage in $WinImages) {
    $curImage = Get-WindowsImage -ImagePath "$mountedDrive\sources\install.wim" -Index $WinImage.ImageIndex
    
    # 使用 PSCustomObject 來創建每個圖像的資訊
    $objImage = [PSCustomObject]@{
        ImageIndex  = $curImage.ImageIndex
        ImageName   = $curImage.ImageName
        Version     = $curImage.Version
        Languages   = $curImage.Languages
        Architecture= $curImage.Architecture
    }
    $Report += $objImage
}

# 卸載 ISO 檔
Dismount-DiskImage $mountResult.ImagePath

# 顯示結果
$Report | Out-GridView
