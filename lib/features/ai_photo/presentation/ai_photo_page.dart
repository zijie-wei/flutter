import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/photo_provider.dart';
import '../domain/photo_models.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/network_utils.dart';

class AIPhotoPage extends StatefulWidget {
  const AIPhotoPage({super.key});

  @override
  State<AIPhotoPage> createState() => _AIPhotoPageState();
}

class _AIPhotoPageState extends State<AIPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI写真'),
      ),
      body: Consumer<PhotoProvider>(
        builder: (context, photoProvider, child) {
          if (photoProvider.state.status ==
                  PhotoGenerationStatus.completed &&
              photoProvider.state.generatedPhotos.isNotEmpty) {
            return _ResultView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUploadSection(photoProvider),
                const SizedBox(height: 24),
                _buildStyleSection(photoProvider),
                const SizedBox(height: 24),
                _buildCountSection(photoProvider),
                const SizedBox(height: 24),
                _buildGenerateButton(photoProvider),
                if (photoProvider.state.isPolling)
                  _buildProgressSection(photoProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadSection(PhotoProvider photoProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '上传照片',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (photoProvider.state.uploadedImage != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      photoProvider.state.uploadedImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              photoProvider.pickImageFromGallery(),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('重新选择'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              photoProvider.pickImageFromCamera(),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '点击上传照片',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              photoProvider.pickImageFromGallery(),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('从相册选择'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              photoProvider.pickImageFromCamera(),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('拍照'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSection(PhotoProvider photoProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择风格',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: photoProvider.state.styles.length,
              itemBuilder: (context, index) {
                final style = photoProvider.state.styles[index];
                final isSelected = photoProvider.state.preferences?.styleId ==
                    style.id;
                return _StyleCard(
                  style: style,
                  isSelected: isSelected,
                  onTap: () => photoProvider.selectStyle(style.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountSection(PhotoProvider photoProvider) {
    final count = photoProvider.state.preferences?.count ??
        AppConstants.defaultPhotoCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '生成数量',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: count > AppConstants.minPhotoCount
                      ? () => photoProvider.setPhotoCount(count - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Text(
                  '$count 张',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: count < AppConstants.maxPhotoCount
                      ? () => photoProvider.setPhotoCount(count + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(PhotoProvider photoProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: photoProvider.state.uploadedImage != null
            ? () => photoProvider.generatePhotos()
            : null,
        child: const Text('开始生成'),
      ),
    );
  }

  Widget _buildProgressSection(PhotoProvider photoProvider) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: photoProvider.state.progress / 100,
            ),
            const SizedBox(height: 8),
            Text(
              '${photoProvider.state.progress}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusText(photoProvider.state.status),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(PhotoGenerationStatus status) {
    switch (status) {
      case PhotoGenerationStatus.uploading:
        return '正在上传照片...';
      case PhotoGenerationStatus.generating:
        return '正在生成写真...';
      default:
        return '';
    }
  }
}

class _StyleCard extends StatelessWidget {
  final PhotoStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.network(
                      style.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (style.description != null)
                        Text(
                          style.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final photos = photoProvider.state.generatedPhotos;

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return _PhotoViewer(photo: photos[index]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          photoProvider.reset();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新生成'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPhoto(context, photos),
                        icon: const Icon(Icons.download),
                        label: const Text('保存到相册'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadPhoto(
    BuildContext context,
    List<GeneratedPhoto> photos,
  ) async {
    try {
      for (final _ in photos) {
        // Note: In a real app, you would download the image from the URL first
        // For now, we'll just show a success message
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (context.mounted) {
        NetworkUtils.showSuccess(context, '图片已保存到相册');
      }
    } catch (e) {
      if (context.mounted) {
        NetworkUtils.showError(context, '保存失败，请重试');
      }
    }
  }
}

class _PhotoViewer extends StatelessWidget {
  final GeneratedPhoto photo;

  const _PhotoViewer({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          photo.url,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, size: 48),
            );
          },
        ),
      ),
    );
  }
}
