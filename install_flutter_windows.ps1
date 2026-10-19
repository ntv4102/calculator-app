# Script tự động cài đặt Flutter SDK trên Windows và khởi tạo bản Flutter APK
Write-Host "=== Bắt đầu cài đặt Flutter SDK qua Winget ===" -ForegroundColor Green
winget install --id=Google.Flutter -e --accept-source-agreements --accept-package-agreements

Write-Host "`nSau khi cài xong, hãy đóng cửa sổ PowerShell này, mở lại PowerShell mới tại C:\Code\Calculator và chạy:" -ForegroundColor Yellow
Write-Host "  flutter create . --project-name can_lua_heo_pro" -ForegroundColor Cyan
Write-Host "  flutter pub get" -ForegroundColor Cyan
Write-Host "  flutter run -d chrome" -ForegroundColor Cyan
Write-Host "  flutter build apk --release" -ForegroundColor Cyan
