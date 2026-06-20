import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/service/archive_download_service.dart';
import 'package:jhentai/src/service/gallery_download_service.dart';

class AnimatedDownloadIcon extends StatefulWidget {
  const AnimatedDownloadIcon({Key? key}) : super(key: key);

  @override
  State<AnimatedDownloadIcon> createState() => _AnimatedDownloadIconState();
}

class _AnimatedDownloadIconState extends State<AnimatedDownloadIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (_hasActiveDownloads()) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasActiveDownloads() {
    final galleryService = Get.find<GalleryDownloadService>();
    final archiveService = Get.find<ArchiveDownloadService>();

    bool hasGalleryDownloading = galleryService.gallerys.any(
      (g) => g.downloadStatusIndex == DownloadStatus.downloading.index,
    );

    bool hasArchiveDownloading = archiveService.archives.any(
      (a) => a.downloadStatusIndex == DownloadStatus.downloading.index,
    );

    return hasGalleryDownloading || hasArchiveDownloading;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GalleryDownloadService>(
      id: galleryDownloadService.galleryCountChangedId,
      builder: (_) => GetBuilder<ArchiveDownloadService>(
        id: archiveDownloadService.galleryCountChangedId,
        builder: (_) {
          bool isActive = _hasActiveDownloads();

          if (isActive && !_controller.isAnimating) {
            _controller.repeat();
          } else if (!isActive && _controller.isAnimating) {
            _controller.stop();
            _controller.reset();
          }

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * pi,
                child: child,
              );
            },
            child: const Icon(Icons.download),
          );
        },
      ),
    );
  }
}
