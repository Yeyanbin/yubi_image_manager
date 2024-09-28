<a href="https://flutter.dev/">
  <h1 align="center">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png">
      <img alt="Flutter" src="https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png">
    </picture>
  </h1>
</a>

# yubi_image_manager

目前仅支持Mac端

## 运行

```
cd image_manager
flutter pub get
flutter run
```

## 仅体验

下载`image_manager.zip`然后解压缩后直接打开。

## 使用的库

```yaml
  cupertino_icons: ^1.0.6 # ios图标
  file_picker: ^5.2.0  # 文件选择插件
  photo_view: ^0.14.0  # 用于图片预览
  exif: ^2.0.1 # 拍摄照片信息
  path: ^1.8.0 # 路径工具
  flutter_riverpod: ^2.0.0  # 状态管理工具
  shared_preferences: ^2.0.0 # 数据持久化工具
```