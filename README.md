# The Movie App

Ứng dụng xem phim được xây dựng bằng Flutter, tập trung vào trải nghiệm tìm phim, xem thông tin phim, phát video tập phim và quản lý danh sách yêu thích.

## Tính năng chính

- Đăng ký / đăng nhập bằng Firebase Authentication.
- Quản lý thông tin người dùng với Cloud Firestore.
- Trang chủ hiển thị phim sắp chiếu, phim theo danh mục.
- Tìm kiếm phim theo từ khóa, gợi ý và quốc gia.
- Xem chi tiết phim: mô tả, thể loại, tập phim liên quan.
- Xem video tập phim với Chewie/Video Player, có lưu tiến trình xem.
- Quản lý danh sách phim yêu thích (thêm/xóa, chọn nhiều).

## Công nghệ sử dụng

- Flutter + Dart
- State management: flutter_bloc
- Firebase Core / Auth / Firestore
- HTTP API (danh sách phim)
- Cached image, video player, chewie
- flutter_dotenv để tách cấu hình môi trường

## Cài đặt nhanh

### 1) Clone và cài dependency

```bash
flutter pub get
```

### 2) Tạo file .env ở thư mục gốc

Nội dung mẫu:

```env
DOMAIN_API=https://your-movie-api-domain/
API_LOAD_IMAGE=https://your-image-cdn-domain/
```

Lưu ý:

- `DOMAIN_API` là base URL API phim (các endpoint như thể loại, tìm kiếm, chi tiết phim).
- `API_LOAD_IMAGE` là base URL dùng để ghép đường dẫn ảnh poster/thumbnail.

### 3) Cấu hình Firebase

- Android: kiểm tra file `android/app/google-services.json`.
- iOS/macOS: kiểm tra cấu hình trong thư mục Runner tương ứng.
- File `lib/firebase_options.dart` đã được dùng để khởi tạo Firebase trong `main.dart`.

### 4) Chạy ứng dụng

```bash
flutter run
```

## Cấu trúc thư mục (rút gọn)

```text
lib/
	Features/
		Auth/
		Home/
		Infor_of_Movie/
		WatchMovie/
		SearchMovie/
		Favorite/
		Profiles/
	Theme/
	main.dart
	MyApp.dart
```

## Luồng chính của app

- `main.dart`: khởi tạo Firebase + nạp biến môi trường `.env`.
- `MyApp.dart`: đăng ký các Bloc/Cubit chính và điều hướng theo trạng thái xác thực.
- Các màn hình trong `Features/` xử lý theo từng domain chức năng.

## Ghi chú

- Dự án đang ưu tiên UI gọn và chỉ hiển thị các thành phần có chức năng thực tế.
- Nếu API thay đổi schema hoặc endpoint, cần cập nhật lại phần Data/Repo tương ứng.

## 📱 Demo & Tải về  
Video demo, file APK và tài khoản test có sẵn tại đây:  
👉 [Google Drive](https://drive.google.com/drive/folders/1tPTn7Ws-l1Oz2UnsBEFUTeawFqI6jkAi?usp=sharing) 