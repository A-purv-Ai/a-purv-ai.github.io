Add-Type -AssemblyName System.Drawing
$imagePath = "milkyway-bg.jpg"
$backupPath = "milkyway-bg-original-9725px.jpg"
$outputPath = "milkyway-bg-4k.jpg"

try {
    $img = [System.Drawing.Image]::FromFile((Resolve-Path $imagePath).Path)
    Write-Host "Original dimensions: $($img.Width)x$($img.Height)"
    
    # Resize to exactly 4K width, preserving aspect ratio
    $maxWidth = 3840
    $height = [math]::Round($img.Height * $maxWidth / $img.Width)
    Write-Host "Resizing to: ${maxWidth}x${height}"
    
    $bmp = New-Object System.Drawing.Bitmap($img, $maxWidth, $height)
    
    # Use maximum quality (95) — visually lossless
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]95)
    
    $bmp.Save($outputPath, $codec, $encoderParams)
    
    $img.Dispose()
    $bmp.Dispose()
    
    $origSize = (Get-Item $imagePath).Length / 1MB
    $newSize = (Get-Item $outputPath).Length / 1MB
    Write-Host "`nOriginal: $([math]::Round($origSize, 2)) MB"
    Write-Host "4K version: $([math]::Round($newSize, 2)) MB"
    Write-Host "Reduction: $([math]::Round((1 - $newSize/$origSize) * 100, 1))%"
    
    # Backup original, replace with 4K version
    Copy-Item $imagePath $backupPath
    Copy-Item $outputPath $imagePath -Force
    Remove-Item $outputPath
    
    Write-Host "`nDone! Original backed up as: $backupPath"
    Write-Host "milkyway-bg.jpg is now the 4K version."
} catch {
    Write-Error "Failed: $_"
}
