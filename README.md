# 🌾🐷 Cân Lúa & Cân Heo Pro (Flutter - Android & iOS)

Ứng dụng di động chuyên dụng hỗ trợ nông dân, thương lái và chủ trang trại **ghi số cân lúa, nông sản, cân heo/gia súc** ngoài đồng ruộng hoặc tại trại nhanh chóng, chính xác và hoạt động **100% Offline** không cần mạng Internet.

---

## ✨ Tính năng nổi bật

1. **Bàn phím nhập số cân siêu tốc (1 tay ngoài nắng)**:
   - Chế độ **Tự thêm 1 số lẻ**: Gõ `525` tự động hiểu là `52.5 kg` (hoặc gõ `1185` -> `118.5 kg`), không tốn thời gian bấm dấu chấm. Có thể bật/tắt linh hoạt ngay trên bàn phím.
   - **Đọc to số cân bằng giọng nói Tiếng Việt (`flutter_tts`)**: Mỗi khi bấm Lưu mã cân, ứng dụng đọc to (VD: *"Năm mươi hai ký rưỡi"*) để người đọc cân và người bấm máy đối chiếu tức thì.
2. **Bảng cân chia cột thông minh (5 hoặc 10 mã/cột)**:
   - Tự động chia từng cột **5 bao/cột** hoặc **10 bao/cột**, tự cộng tổng từng cột ở chân bảng và tự cuộn ngang sang cột mới.
   - Chạm vào bất kỳ ô nào đã nhập để **Sửa** hoặc **Xoá** nếu bấm nhầm, hoặc bấm nút **Hoàn tác** mã vừa nhập.
3. **Quy tắc Trừ Bì & Trừ Tạp Chất / Độ Ẩm chuẩn thực tế**:
   - **Kiểu 1 (Miền Tây hay dùng khi cân lúa)**: Quy tắc `X bao = 1 kg` (VD: `7 bao = 1 kg`, `8 bao = 1 kg`).
   - **Kiểu 2 (Cân heo có lồng hoặc trừ bao cố định)**: Trừ `X kg / 1 lồng` (VD: `12 kg/lồng`) hoặc `0.15 kg/bao`.
   - **Kiểu 3**: Nhập tổng số kg bì trực tiếp.
   - Hỗ trợ làm tròn số kg trừ bì đến `0.5 kg` và trừ độ ẩm/tạp chất theo `%` hoặc `kg`.
4. **Tính Thành Tiền, Trừ Tiền Cọc & Đọc Số Tiền Bằng Chữ**:
   - Tự động nhân đơn giá (`đ/kg`), trừ tiền đặt cọc trước và chi phí phụ (bốc vác, xe chở).
   - Tự động chuyển số tiền còn lại sang chữ tiếng Việt.
5. **Xuất Phiếu Cân gửi Zalo & In Máy In Nhiệt Bluetooth / PDF**:
   - Chia sẻ phiếu cân trực tiếp qua **Zalo / Messenger / Tin nhắn**.
   - Xuất file **PDF khổ A4** hoặc **Khổ giấy in nhiệt 80mm (Roll 80mm)**.
6. **Quản lý Danh bạ Thương lái / Nông dân & Thống kê theo Mùa vụ**:
   - Lưu lịch sử giao dịch theo từng khách hàng và tổng hợp sản lượng (tấn), tổng tiền theo từng mùa vụ.

---

## 📂 Cấu trúc mã nguồn

```text
c:\Code\Calculator
├── pubspec.yaml                      # Cấu hình thư viện Flutter
├── lib/
│   ├── main.dart                     # Điểm khởi chạy ứng dụng & cấu hình Tiếng Việt
│   ├── models/
│   │   └── weighing_models.dart      # Models: Phiếu cân, Mã cân, Trừ bì, Danh bạ, Mùa vụ
│   ├── providers/
│   │   └── app_provider.dart         # Quản lý trạng thái (Provider) & lưu trữ tự động
│   ├── services/
│   │   ├── storage_service.dart      # Lưu trữ Offline (SharedPreferences) & Dữ liệu mẫu
│   │   ├── tts_service.dart          # Đọc giọng nói Tiếng Việt (Flutter TTS)
│   │   └── export_service.dart       # Xuất PDF A4 / Hoá đơn nhiệt 80mm & Chia sẻ Zalo
│   ├── screens/
│   │   ├── home_screen.dart          # Màn hình chính & tạo phiếu cân nhanh
│   │   ├── weighing_screen.dart      # Màn hình Bảng cân nhiều cột + Bàn phím + Tính tiền
│   │   ├── receipt_preview_screen.dart # Xem trước phiếu cân, gửi Zalo & In PDF
│   │   ├── contacts_screen.dart      # Quản lý Danh bạ Nông dân / Thương lái
│   │   └── statistics_screen.dart    # Quản lý Mùa vụ & Thống kê tổng hợp
│   └── utils/
│       └── formatters.dart           # Định dạng tiền tệ, số cân & đọc số thành chữ
└── test/
    └── weighing_logic_test.dart      # Unit test kiểm tra công thức tính cân & trừ bì
```

---

## 🚀 Hướng dẫn cài đặt Flutter & Chạy ứng dụng

### Bước 1: Cài đặt Flutter SDK (Nếu máy chưa cài)
1. Tải Flutter SDK cho Windows tại: https://docs.flutter.dev/get-started/install/windows/mobile
   *(Hoặc dùng lệnh Winget trên PowerShell: `winget install --id=Google.Flutter -e`)*
2. Giải nén vào `C:\src\flutter` và thêm `C:\src\flutter\bin` vào biến môi trường `PATH` của Windows.
3. Mở terminal mới và kiểm tra:
   ```powershell
   flutter doctor
   ```

### Bước 2: Khởi tạo thư mục nền tảng Android / iOS và tải thư viện
Mở PowerShell tại thư mục `c:\Code\Calculator` và chạy:

```powershell
# Tạo các thư mục cấu hình gốc (android/, ios/, web/, windows/) mà không ghi đè code trong lib/
flutter create . --project-name can_lua_heo_pro

# Tải các gói thư viện trong pubspec.yaml
flutter pub get
```

### Bước 3: Chạy thử nghiệm và Kiểm tra Unit Test
```powershell
# Chạy kiểm tra công thức tính toán
flutter test

# Chạy ứng dụng trên máy ảo Android / điện thoại thật (cắm cáp USB bật USB Debugging) hoặc trình duyệt Chrome
flutter run
```

### Bước 4: Đóng gói file cài đặt `.apk` cho điện thoại Android
```powershell
flutter build apk --release
```
Sau khi chạy xong, file cài đặt `.apk` sẽ nằm tại:
`build\app\outputs\flutter-apk\app-release.apk` — bạn chỉ cần gửi file này qua Zalo vào điện thoại Android là cài đặt và sử dụng được ngay!
