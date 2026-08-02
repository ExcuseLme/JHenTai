import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:jhentai/src/mixin/scroll_to_top_logic_mixin.dart';
import 'package:jhentai/src/mixin/scroll_to_top_state_mixin.dart';

mixin Scroll2TopPageMixin on Widget {
  Scroll2TopLogicMixin get scroll2TopLogic;

  Scroll2TopStateMixin get scroll2TopState;

  Widget buildFloatingActionButton() {
    return GetBuilder<Scroll2TopLogicMixin>(
      id: scroll2TopLogic.scroll2TopButtonId,
      global: false,
      init: scroll2TopLogic,
      builder: (_) {
        final List<Widget> buttons = [];

        if (scroll2TopLogic.shouldDisplayFAB) {
          buttons.add(
            Opacity(
              opacity: 0.5,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: scroll2TopLogic.scroll2Top,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
          );
        }

        if (scroll2TopLogic.shouldDisplayScrollBottomFAB) {
          buttons.add(
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Opacity(
                opacity: 0.5,
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: scroll2TopLogic.scroll2Bottom,
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: buttons.isEmpty ? null : Column(
            key: ValueKey(buttons.length),
            mainAxisSize: MainAxisSize.min,
            children: buttons,
          ),
        );
      },
    );
  }
}
