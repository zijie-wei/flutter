import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/photo_models.dart';

enum PhotoGenerationStatus {
  initial,
  uploading,
  generating,
  completed,
  failed,
}

class PhotoState {
  final PhotoGenerationStatus status;
  final List<PhotoStyle> styles;
  final List<GeneratedPhoto> generatedPhotos;
  final PhotoPreferences? preferences;
  final File? uploadedImage;
  final String? errorMessage;
  final String? generationId;
  final bool isPolling;
  final int progress;

  PhotoState({
    this.status = PhotoGenerationStatus.initial,
    this.styles = const [],
    this.generatedPhotos = const [],
    this.preferences,
    this.uploadedImage,
    this.errorMessage,
    this.generationId,
    this.isPolling = false,
    this.progress = 0,
  });

  PhotoState copyWith({
    PhotoGenerationStatus? status,
    List<PhotoStyle>? styles,
    List<GeneratedPhoto>? generatedPhotos,
    PhotoPreferences? preferences,
    File? uploadedImage,
    String? errorMessage,
    String? generationId,
    bool? isPolling,
    int? progress,
    bool clearUploadedImage = false,
  }) {
    return PhotoState(
      status: status ?? this.status,
      styles: styles ?? this.styles,
      generatedPhotos: generatedPhotos ?? this.generatedPhotos,
      preferences: preferences ?? this.preferences,
      uploadedImage: clearUploadedImage ? null : (uploadedImage ?? this.uploadedImage),
      errorMessage: errorMessage,
      generationId: generationId ?? this.generationId,
      isPolling: isPolling ?? this.isPolling,
      progress: progress ?? this.progress,
    );
  }
}

class PhotoProvider extends ChangeNotifier {
  Timer? _pollingTimer;

  PhotoState _state = PhotoState();
  PhotoState get state => _state;

  PhotoProvider() {
    _loadPreferences();
    _loadStyles();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(StorageKeys.photoPreferences);

    if (preferencesJson != null) {
      try {
        final preferences = PhotoPreferences.fromJson(
          Map<String, dynamic>.from(
            await compute(_parsePreferences, preferencesJson),
          ),
        );
        _state = _state.copyWith(preferences: preferences);
        notifyListeners();
      } catch (e) {
        // Use default preferences if parsing fails
      }
    } else {
      _state = _state.copyWith(
        preferences: PhotoPreferences(
          styleId: '',
          count: AppConstants.defaultPhotoCount,
        ),
      );
      notifyListeners();
    }
  }

  static Map<String, dynamic> _parsePreferences(String json) {
    return Map<String, dynamic>.from(
      json.split(',').fold<Map<String, dynamic>>(
        {},
        (map, item) {
          final parts = item.split(':');
          if (parts.length == 2) {
            map[parts[0].trim()] = parts[1].trim();
          }
          return map;
        },
      ),
    );
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_state.preferences != null) {
      await prefs.setString(
        StorageKeys.photoPreferences,
        _state.preferences!.toString(),
      );
    }
  }

  Future<void> _loadStyles() async {
    await Future.delayed(const Duration(milliseconds: 300));

    _state = _state.copyWith(
      styles: _getDefaultStyles(),
    );
    notifyListeners();
  }

  List<PhotoStyle> _getDefaultStyles() {
    return [
      PhotoStyle(
        id: '1',
        name: '自然风格',
        thumbnail: 'https://via.placeholder.com/150',
        description: '清新自然，适合日常使用',
      ),
      PhotoStyle(
        id: '2',
        name: '艺术风格',
        thumbnail: 'https://via.placeholder.com/150',
        description: '艺术感强，适合创意作品',
      ),
      PhotoStyle(
        id: '3',
        name: '复古风格',
        thumbnail: 'https://via.placeholder.com/150',
        description: '怀旧复古，适合经典照片',
      ),
      PhotoStyle(
        id: '4',
        name: '时尚风格',
        thumbnail: 'https://via.placeholder.com/150',
        description: '时尚潮流，适合社交媒体',
      ),
    ];
  }

  Future<void> pickImageFromGallery() async {
    final image = await ImageUtils.pickImageFromGallery();
    if (image != null) {
      final compressedImage = await ImageUtils.compressImage(
        image,
        AppConstants.maxImageSize ~/ 1024,
      );
      _state = _state.copyWith(uploadedImage: compressedImage);
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    final image = await ImageUtils.pickImageFromCamera();
    if (image != null) {
      final compressedImage = await ImageUtils.compressImage(
        image,
        AppConstants.maxImageSize ~/ 1024,
      );
      _state = _state.copyWith(uploadedImage: compressedImage);
      notifyListeners();
    }
  }

  void selectStyle(String styleId) {
    if (_state.preferences != null) {
      _state = _state.copyWith(
        preferences: _state.preferences!.copyWith(styleId: styleId),
      );
      notifyListeners();
      _savePreferences();
    }
  }

  void setPhotoCount(int count) {
    if (_state.preferences != null) {
      _state = _state.copyWith(
        preferences: _state.preferences!.copyWith(count: count),
      );
      notifyListeners();
      _savePreferences();
    }
  }

  Future<void> generatePhotos() async {
    if (_state.uploadedImage == null) {
      _state = _state.copyWith(
        errorMessage: '请先上传照片',
      );
      notifyListeners();
      return;
    }

    if (_state.preferences?.styleId == null ||
        _state.preferences!.styleId.isEmpty) {
      _state = _state.copyWith(
        errorMessage: '请选择风格',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      status: PhotoGenerationStatus.uploading,
      errorMessage: null,
      progress: 10,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final generationId = 'gen_${DateTime.now().millisecondsSinceEpoch}';

    _state = _state.copyWith(
      status: PhotoGenerationStatus.generating,
      generationId: generationId,
      progress: 30,
    );
    notifyListeners();

    await _startGenerationPolling(generationId);
  }

  Future<void> _startGenerationPolling(String generationId) async {
    _state = _state.copyWith(isPolling: true);
    notifyListeners();

    int elapsed = 0;
    int progress = 30;

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        elapsed += 1000;
        progress = (progress + 5).clamp(30, 95);

        _state = _state.copyWith(progress: progress);
        notifyListeners();

        if (elapsed >= 5000) {
          timer.cancel();

          final count = _state.preferences?.count ?? AppConstants.defaultPhotoCount;
          final generatedPhotos = List.generate(
            count,
            (index) => GeneratedPhoto(
              id: '${generationId}_$index',
              url: 'https://via.placeholder.com/400x600?text=Photo+${index + 1}',
              status: 'completed',
              createdAt: DateTime.now(),
            ),
          );

          _state = _state.copyWith(
            status: PhotoGenerationStatus.completed,
            generatedPhotos: generatedPhotos,
            isPolling: false,
            progress: 100,
          );
          notifyListeners();
        }
      },
    );
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  void reset() {
    _pollingTimer?.cancel();
    _state = PhotoState(
      preferences: _state.preferences,
      styles: _state.styles,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
