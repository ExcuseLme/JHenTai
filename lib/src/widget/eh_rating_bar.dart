import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jhentai/src/config/ui_config.dart';

/// 自定义评分栏，点击星星之间的空白区也能触发评分
class EHRatingBar extends StatefulWidget {
  final double initialRating;
  final int itemCount;
  final bool allowHalfRating;
  final double itemSize;
  final Color? unratedColor;
  final Color ratedColor;
  final ValueChanged<double> onRatingUpdate;

  const EHRatingBar({
    Key? key,
    required this.initialRating,
    this.itemCount = 5,
    this.allowHalfRating = true,
    required this.itemSize,
    this.unratedColor,
    required this.ratedColor,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  State<EHRatingBar> createState() => _EHRatingBarState();
}

class _EHRatingBarState extends State<EHRatingBar> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _handleDragUpdate,
      onTapUp: _handleTapUp,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.itemCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              _getIconForIndex(index),
              size: widget.itemSize,
              color: _getColorForIndex(index),
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    double starRating = _currentRating - index;
    if (starRating >= 1) {
      return Icons.star;
    } else if (starRating >= 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getColorForIndex(int index) {
    double starRating = _currentRating - index;
    if (starRating > 0) {
      return widget.ratedColor;
    } else {
      return widget.unratedColor ?? Colors.grey;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _updateRatingFromPosition(details.localPosition.dx);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _updateRatingFromPosition(details.localPosition.dx);
  }

  void _updateRatingFromPosition(double dx) {
    // 计算每个星星的宽度（包括间距）
    double itemWidth = widget.itemSize + 4; // itemSize + padding

    // 计算点击位置对应的评分
    double rating = (dx / itemWidth) + 0.5;

    // 限制范围
    rating = rating.clamp(0.5, widget.itemCount.toDouble());

    // 如果不允许半星，取整
    if (!widget.allowHalfRating) {
      rating = rating.roundToDouble();
    } else {
      // 允许半星，四舍五入到 0.5
      rating = (rating * 2).roundToDouble() / 2;
    }

    if (rating != _currentRating) {
      setState(() {
        _currentRating = rating;
      });
      widget.onRatingUpdate(rating);
    }
  }
}
