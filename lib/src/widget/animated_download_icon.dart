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
      duration: const Duration(seconds: 1),
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
      (a) => a.archiveStatusCode >= ArchiveStatus.unlocking.code && a.archiveStatusCode <= ArchiveStatus.unpacking.code,
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
              return CustomPaint(
                painter: _SpinningRingPainter(
                  progress: _animation.value,
                  isActive: isActive,
                ),
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

class _SpinningRingPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _SpinningRingPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + 2;
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final startAngle = progress * 2 * pi;
    const sweepAngle = pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinningRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
