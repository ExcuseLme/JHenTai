import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:jhentai/src/mixin/scroll_to_top_logic_mixin.dart';
import 'package:jhentai/src/mixin/scroll_to_top_state_mixin.dart';

mixin Scroll2TopPageMixin on Widget {
  Scroll2TopLogicMixin get scroll2TopLogic;

  Scroll2TopStateMixin get scroll2TopState;

  /// 刷新回调，子类可重写
  VoidCallback? get onRefresh => null;

  /// 刷新状态，子类可重写
  RxBool? get refreshState => null;

  Widget buildFloatingActionButton() {
    return GetBuilder<Scroll2TopLogicMixin>(
      id: scroll2TopLogic.scroll2TopButtonId,
      global: false,
      init: scroll2TopLogic,
      builder: (_) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: scroll2TopLogic.shouldDisplayFAB
              ? Opacity(
                  opacity: 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onRefresh != null)
                        _buildRefreshButton(),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: null,
                        onPressed: scroll2TopLogic.scroll2Top,
                        child: const Icon(Icons.arrow_upward),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildRefreshButton() {
    return FloatingActionButton(
      heroTag: null,
      onPressed: onRefresh,
      child: refreshState?.value == true
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh),
    );
  }
}
