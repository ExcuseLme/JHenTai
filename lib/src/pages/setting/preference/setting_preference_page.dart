import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/extension/widget_extension.dart';
import 'package:jhentai/src/model/tab_bar_icon.dart';
import 'package:jhentai/src/service/tag_search_order_service.dart';
import 'package:jhentai/src/utils/text_input_formatter.dart';
import 'package:jhentai/src/utils/toast_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../config/ui_config.dart';
import '../../../consts/locale_consts.dart';
import '../../../l18n/locale_text.dart';
import '../../../model/jh_layout.dart';
import '../../../routes/routes.dart';
import '../../../service/tag_translation_service.dart';
import '../../../setting/preference_setting.dart';
import '../../../setting/style_setting.dart';
import '../../../utils/locale_util.dart';
import '../../../utils/route_util.dart';
import '../../../widget/eh_gallery_category_tag.dart';
import '../../../widget/loading_state_indicator.dart';

class SettingPreferencePage extends StatelessWidget {
  final TextEditingController drawerGestureEdgeWidthController =
      TextEditingController(text: preferenceSetting.drawerGestureEdgeWidth.value.toString());
  final TextEditingController scrollSensitivityController =
      TextEditingController(text: preferenceSetting.scrollSensitivity.value.toStringAsFixed(1));

  SettingPreferencePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('preferenceSetting'.tr)),
      body: Obx(
        () => SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 16),
            children: [
              _buildLanguage(),
              _buildTagTranslate(),
              _buildTagOrderOptimization(),
              _buildDefaultTab(),
              if (styleSetting.isInV2Layout) _buildSimpleDashboardMode(),
              if (styleSetting.isInV2Layout) _buildShowBottomNavigation(),
              if (styleSetting.isInV2Layout || styleSetting.actualLayout == LayoutMode.desktop) _buildHideScroll2TopButton(),
              _buildPreloadGalleryCover(),
              _buildEnableSwipeBackGesture(),
              if (styleSetting.isInV2Layout) _buildEnableLeftMenuDrawerGesture(),
              if (styleSetting.isInV2Layout) _buildQuickSearch(),
              if (styleSetting.isInV2Layout) _buildDrawerGestureEdgeWidth(context),
              _buildScrollSensitivity(context),
              _buildShowAllGalleryTitles(),
              _buildShowGalleryTagVoteStatus(),
              _buildShowComments(),
              if (preferenceSetting.showComments.isTrue) _buildShowAllComments().fadeIn(const Key('showAllComments')),
              _buildEnableDefaultFavorite(),
              _buildEnableDefaultTagSet(),
              if (GetPlatform.isDesktop && styleSetting.isInDesktopLayout) _buildLaunchInFullScreen(),
              _buildTagSearchConfig(),
              _buildEnableAutoLanguageFilter(),
              if (preferenceSetting.enableAutoLanguageFilter.isTrue) ...[
                _buildAutoLanguageFilterCategories(context).fadeIn(const Key('autoLanguageFilterCategories')),
                _buildAutoLanguageFilterTarget().fadeIn(const Key('autoLanguageFilterTarget')),
              ],
              if (preferenceSetting.enableTagZHTranslation.isTrue) _buildShowR18GImageDirectly().fadeIn(const Key('showR18GImageDirectly')),
              _buildShowUtcTime(),
              _buildShowDawnInfo(),
              _buildShowEncounterMonster(),
              _buildUseBuiltInBlockedUsers(),
              _buildBlockRules(),
            ],
          ).withListTileTheme(context),
        ),
      ),
    );
  }

  Widget _buildLanguage() {
    return ListTile(
      title: Text('language'.tr),
      trailing: DropdownButton<Locale>(
        value: preferenceSetting.locale.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (Locale? newValue) => preferenceSetting.saveLanguage(newValue!),
        items: LocaleText()
            .keys
            .keys
            .map((localeCode) => DropdownMenuItem(
                  child: Text(LocaleConsts.localeCode2Description[localeCode]!),
                  value: localeCode2Locale(localeCode),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTagTranslate() {
    return ListTile(
      title: Text('enableTagZHTranslation'.tr),
      subtitle: tagTranslationService.loadingState.value == LoadingState.success
          ? Text('${'version'.tr}: ${tagTranslationService.timeStamp.value!}', style: const TextStyle(fontSize: 12))
          : tagTranslationService.loadingState.value == LoadingState.loading
              ? Text(
                  '${'downloadTagTranslationHint'.tr}${tagTranslationService.downloadProgress.value}',
                  style: const TextStyle(fontSize: 12),
                )
              : tagTranslationService.loadingState.value == LoadingState.error
                  ? Text('downloadFailed'.tr, style: const TextStyle(fontSize: 12))
                  : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            useCupertinoIndicator: true,
            loadingState: tagTranslationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidgetBuilder: () => IconButton(onPressed: tagTranslationService.fetchDataFromGithub, icon: const Icon(Icons.refresh)),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          Switch(
            value: preferenceSetting.enableTagZHTranslation.value,
            onChanged: (value) {
              preferenceSetting.saveEnableTagZHTranslation(value);
              if (value == true && tagTranslationService.loadingState.value != LoadingState.success) {
                tagTranslationService.fetchDataFromGithub();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTagOrderOptimization() {
    return ListTile(
      title: Text('zhTagSearchOrderOptimization'.tr),
      subtitle: tagSearchOrderOptimizationService.loadingState.value == LoadingState.success
          ? Text('${'version'.tr}: ${tagSearchOrderOptimizationService.version.value!}', style: const TextStyle(fontSize: 12))
          : tagSearchOrderOptimizationService.loadingState.value == LoadingState.loading
              ? Text(
                  '${'downloadTagTranslationHint'.tr}${tagSearchOrderOptimizationService.downloadProgress.value}',
                  style: const TextStyle(fontSize: 12),
                )
              : tagSearchOrderOptimizationService.loadingState.value == LoadingState.error
                  ? Text('downloadFailed'.tr, style: const TextStyle(fontSize: 12))
                  : Text('zhTagSearchOrderOptimizationHint'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStateIndicator(
            useCupertinoIndicator: true,
            loadingState: tagSearchOrderOptimizationService.loadingState.value,
            indicatorRadius: 10,
            width: 40,
            idleWidgetBuilder: () => IconButton(onPressed: tagSearchOrderOptimizationService.fetchDataFromGithub, icon: const Icon(Icons.refresh)),
            errorWidgetSameWithIdle: true,
            successWidgetSameWithIdle: true,
          ),
          Switch(
            value: preferenceSetting.enableTagZHSearchOrderOptimization.value,
            onChanged: (value) {
              preferenceSetting.saveEnableTagZHSearchOrderOptimization(value);
              if (value == true && tagSearchOrderOptimizationService.loadingState.value != LoadingState.success) {
                tagSearchOrderOptimizationService.fetchDataFromGithub();
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildDefaultTab() {
    return ListTile(
      title: Text('defaultTab'.tr),
      trailing: DropdownButton<TabBarIconNameEnum>(
        value: preferenceSetting.defaultTab.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (TabBarIconNameEnum? newValue) => preferenceSetting.saveDefaultTab(newValue!),
        items: [
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.home.name.tr),
            value: TabBarIconNameEnum.home,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.popular.name.tr),
            value: TabBarIconNameEnum.popular,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.ranklist.name.tr),
            value: TabBarIconNameEnum.ranklist,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.favorite.name.tr),
            value: TabBarIconNameEnum.favorite,
          ),
          DropdownMenuItem(
            child: Text(TabBarIconNameEnum.watched.name.tr),
            value: TabBarIconNameEnum.watched,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDashboardMode() {
    return SwitchListTile(
      title: Text('simpleDashboardMode'.tr),
      subtitle: Text('simpleDashboardModeHint'.tr),
      value: preferenceSetting.simpleDashboardMode.value,
      onChanged: preferenceSetting.saveSimpleDashboardMode,
    );
  }

  Widget _buildShowBottomNavigation() {
    return SwitchListTile(
      title: Text('hideBottomBar'.tr),
      value: preferenceSetting.hideBottomBar.value,
      onChanged: preferenceSetting.saveHideBottomBar,
    );
  }

  Widget _buildHideScroll2TopButton() {
    return ListTile(
      title: Text('hideScroll2TopButton'.tr),
      trailing: DropdownButton<Scroll2TopButtonModeEnum>(
        value: preferenceSetting.hideScroll2TopButton.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (Scroll2TopButtonModeEnum? newValue) => preferenceSetting.saveHideScroll2TopButton(newValue!),
        items: [
          DropdownMenuItem(
            child: Text('whenScrollUp'.tr),
            value: Scroll2TopButtonModeEnum.scrollUp,
          ),
          DropdownMenuItem(
            child: Text('whenScrollDown'.tr),
            value: Scroll2TopButtonModeEnum.scrollDown,
          ),
          DropdownMenuItem(
            child: Text('never'.tr),
            value: Scroll2TopButtonModeEnum.never,
          ),
          DropdownMenuItem(
            child: Text('always'.tr),
            value: Scroll2TopButtonModeEnum.always,
          ),
        ],
      ),
    );
  }

  Widget _buildPreloadGalleryCover() {
    return SwitchListTile(
      title: Text('preloadGalleryCover'.tr),
      subtitle: Text('preloadGalleryCoverHint'.tr),
      value: preferenceSetting.preloadGalleryCover.value,
      onChanged: preferenceSetting.savePreloadGalleryCover,
    );
  }

  Widget _buildEnableSwipeBackGesture() {
    return SwitchListTile(
      title: Text('enableSwipeBackGesture'.tr),
      subtitle: Text('needRestart'.tr),
      value: preferenceSetting.enableSwipeBackGesture.value,
      onChanged: preferenceSetting.saveEnableSwipeBackGesture,
    );
  }

  Widget _buildEnableLeftMenuDrawerGesture() {
    return SwitchListTile(
      title: Text('enableLeftMenuDrawerGesture'.tr),
      value: preferenceSetting.enableLeftMenuDrawerGesture.value,
      onChanged: preferenceSetting.saveEnableLeftMenuDrawerGesture,
    );
  }

  Widget _buildQuickSearch() {
    return SwitchListTile(
      title: Text('enableQuickSearchDrawerGesture'.tr),
      value: preferenceSetting.enableQuickSearchDrawerGesture.value,
      onChanged: preferenceSetting.saveEnableQuickSearchDrawerGesture,
    );
  }

  Widget _buildDrawerGestureEdgeWidth(BuildContext context) {
    return ListTile(
      title: Text('drawerGestureEdgeWidth'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: TextField(
              controller: drawerGestureEdgeWidthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(isDense: true, labelStyle: TextStyle(fontSize: 12)),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          Text('px', style: UIConfig.settingPageListTileTrailingTextStyle(context)),
          IconButton(
            onPressed: () {
              int? value = int.tryParse(drawerGestureEdgeWidthController.value.text);
              if (value == null) {
                drawerGestureEdgeWidthController.text = '20';
                value = 20;
              } else if (value < 20) {
                drawerGestureEdgeWidthController.text = '20';
                value = 20;
              } else if (value > 300) {
                drawerGestureEdgeWidthController.text = '300';
                value = 300;
              }
              preferenceSetting.saveDrawerGestureEdgeWidth(value);
              toast('saveSuccess'.tr);
            },
            icon: Icon(Icons.check, color: UIConfig.resumePauseButtonColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollSensitivity(BuildContext context) {
    return ListTile(
      title: Text('scrollSensitivity'.tr),
      subtitle: Text('scrollSensitivityHint'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: TextField(
              controller: scrollSensitivityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(isDense: true, labelStyle: TextStyle(fontSize: 12)),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              double? value = double.tryParse(scrollSensitivityController.value.text);
              if (value == null || value < 1.0) {
                scrollSensitivityController.text = '1.0';
                value = 1.0;
              }
              preferenceSetting.saveScrollSensitivity(value);
              toast('saveSuccess'.tr);
            },
            icon: Icon(Icons.check, color: UIConfig.resumePauseButtonColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildShowAllGalleryTitles() {
    return SwitchListTile(
      title: Text('showAllGalleryTitles'.tr),
      subtitle: Text('showAllGalleryTitlesHint'.tr),
      value: preferenceSetting.showAllGalleryTitles.value,
      onChanged: preferenceSetting.saveShowAllGalleryTitles,
    );
  }

  Widget _buildShowGalleryTagVoteStatus() {
    return SwitchListTile(
      title: Text('showGalleryTagVoteStatus'.tr),
      subtitle: Text('showGalleryTagVoteStatusHint'.tr),
      value: preferenceSetting.showGalleryTagVoteStatus.value,
      onChanged: preferenceSetting.saveShowGalleryTagVoteStatus,
    );
  }

  Widget _buildShowComments() {
    return SwitchListTile(
      title: Text('showComments'.tr),
      value: preferenceSetting.showComments.value,
      onChanged: preferenceSetting.saveShowComments,
    );
  }

  Widget _buildShowAllComments() {
    return SwitchListTile(
      title: Text('showAllComments'.tr),
      subtitle: Text('showAllCommentsHint'.tr),
      value: preferenceSetting.showAllComments.value,
      onChanged: preferenceSetting.saveShowAllComments,
    );
  }

  Widget _buildShowR18GImageDirectly() {
    return SwitchListTile(
      title: Text('showR18GImageDirectly'.tr),
      value: preferenceSetting.showR18GImageDirectly.value,
      onChanged: preferenceSetting.saveShowR18GImageDirectly,
    );
  }

  Widget _buildEnableDefaultFavorite() {
    return SwitchListTile(
      title: Text('enableDefaultFavorite'.tr),
      subtitle: Text(preferenceSetting.enableDefaultFavorite.isTrue ? 'enableDefaultFavoriteHint'.tr : 'disableDefaultFavoriteHint'.tr),
      value: preferenceSetting.enableDefaultFavorite.value,
      onChanged: preferenceSetting.saveEnableDefaultFavorite,
    );
  }

  Widget _buildEnableDefaultTagSet() {
    return SwitchListTile(
      title: Text('enableDefaultTagSet'.tr),
      subtitle: Text(preferenceSetting.enableDefaultTagSet.isTrue ? 'enableDefaultTagSetHint'.tr : 'disableDefaultTagSetHint'.tr),
      value: preferenceSetting.enableDefaultTagSet.value,
      onChanged: preferenceSetting.saveEnableDefaultTagSet,
    );
  }

  Widget _buildLaunchInFullScreen() {
    return SwitchListTile(
      title: Text('launchInFullScreen'.tr),
      subtitle: Text('launchInFullScreenHint'.tr),
      value: preferenceSetting.launchInFullScreen.value,
      onChanged: preferenceSetting.saveLaunchInFullScreen,
    );
  }

  Widget _buildTagSearchConfig() {
    return ListTile(
      title: Text('searchBehaviour'.tr),
      subtitle: Text(
        preferenceSetting.searchBehaviour.value == SearchBehaviour.inheritAll
            ? 'inheritAllHint'.tr
            : preferenceSetting.searchBehaviour.value == SearchBehaviour.inheritPartially
                ? 'inheritPartiallyHint'.tr
                : 'noneHint'.tr,
      ),
      trailing: DropdownButton<SearchBehaviour>(
        value: preferenceSetting.searchBehaviour.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (SearchBehaviour? newValue) => preferenceSetting.saveTagSearchConfig(newValue!),
        items: [
          DropdownMenuItem(
            child: Text('inheritAll'.tr),
            value: SearchBehaviour.inheritAll,
          ),
          DropdownMenuItem(
            child: Text('inheritPartially'.tr),
            value: SearchBehaviour.inheritPartially,
          ),
          DropdownMenuItem(
            child: Text('none'.tr),
            value: SearchBehaviour.none,
          ),
        ],
      ),
    );
  }

  Widget _buildEnableAutoLanguageFilter() {
    return SwitchListTile(
      title: Text('enableAutoLanguageFilter'.tr),
      subtitle: Text('enableAutoLanguageFilterHint'.tr),
      value: preferenceSetting.enableAutoLanguageFilter.value,
      onChanged: preferenceSetting.saveEnableAutoLanguageFilter,
    );
  }

  Widget _buildAutoLanguageFilterCategories(BuildContext context) {
    List<String> allCategories = [
      'Doujinshi',
      'Manga',
      'Image Set',
      'Game CG',
      'Artist CG',
      'Cosplay',
      'Non-H',
      'Asian Porn',
      'Western',
      'Misc',
    ];

    return ListTile(
      title: Text('autoLanguageFilterCategories'.tr),
      subtitle: Text('autoLanguageFilterCategoriesHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => _CategorySelectDialog(
            selectedCategories: preferenceSetting.autoLanguageFilterCategories.toList(),
            allCategories: allCategories,
            onConfirm: (selected) {
              preferenceSetting.saveAutoLanguageFilterCategories(selected);
            },
          ),
        );
      },
    );
  }

  Widget _buildAutoLanguageFilterTarget() {
    return ListTile(
      title: Text('autoLanguageFilterTarget'.tr),
      subtitle: Text('autoLanguageFilterTargetHint'.tr),
      trailing: DropdownButton<String?>(
        value: preferenceSetting.autoLanguageFilterTarget.value,
        elevation: 4,
        alignment: AlignmentDirectional.centerEnd,
        onChanged: (String? newValue) => preferenceSetting.saveAutoLanguageFilterTarget(newValue),
        menuMaxHeight: 200,
        items: [
          DropdownMenuItem(child: Text('nope'.tr), value: null),
          ...LocaleConsts.language2Abbreviation.keys
              .where((language) => language != 'japanese')
              .map((language) => DropdownMenuItem(child: Text(language.capitalizeFirst!), value: language))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildShowUtcTime() {
    return SwitchListTile(
      title: Text('showUtcTime'.tr),
      value: preferenceSetting.showUtcTime.value,
      onChanged: preferenceSetting.saveShowUtcTime,
    );
  }

  Widget _buildBlockRules() {
    return ListTile(
      title: Text('blockingRules'.tr),
      subtitle: Text('blockingRulesHint'.tr),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => toRoute(Routes.blockingRules),
    );
  }

  Widget _buildShowDawnInfo() {
    return SwitchListTile(
      title: Text('showDawnInfo'.tr),
      value: preferenceSetting.showDawnInfo.value,
      onChanged: preferenceSetting.saveShowDawnInfo,
    );
  }

  Widget _buildShowEncounterMonster() {
    return SwitchListTile(
      title: Text('showEncounterMonster'.tr),
      value: preferenceSetting.showHVInfo.value,
      onChanged: preferenceSetting.saveShowHVInfo,
    );
  }

  Widget _buildUseBuiltInBlockedUsers() {
    return ListTile(
      title: Text('useBuiltInBlockedUsers'.tr),
      subtitle: Text('useBuiltInBlockedUsersHint'.tr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => launchUrlString(
              'https://raw.githubusercontent.com/jiangtian616/JHenTai/refs/heads/master/built_in_blocked_user.json',
              mode: LaunchMode.externalApplication,
            ),
          ),
          Switch(
            value: preferenceSetting.useBuiltInBlockedUsers.value,
            onChanged: preferenceSetting.saveUseBuiltInBlockedUsers,
          )
        ],
      ),
    );
  }
}

class _CategorySelectDialog extends StatefulWidget {
  final List<String> selectedCategories;
  final List<String> allCategories;
  final ValueChanged<List<String>> onConfirm;

  const _CategorySelectDialog({
    Key? key,
    required this.selectedCategories,
    required this.allCategories,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_CategorySelectDialog> createState() => _CategorySelectDialogState();
}

class _CategorySelectDialogState extends State<_CategorySelectDialog> {
  late List<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = List.from(widget.selectedCategories);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  Widget _buildTag(String category) {
    return EHGalleryCategoryTag(
      category: category,
      width: 115,
      height: 30,
      enabled: selectedCategories.contains(category),
      onTap: () => _toggleCategory(category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('autoLanguageFilterCategories'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('Doujinshi'), _buildTag('Manga')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('Image Set'), _buildTag('Game CG')],
          ).marginOnly(top: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('Artist CG'), _buildTag('Cosplay')],
          ).marginOnly(top: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('Non-H'), _buildTag('Asian Porn')],
          ).marginOnly(top: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('Western'), _buildTag('Misc')],
          ).marginOnly(top: 4),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(selectedCategories);
            Navigator.of(context).pop();
          },
          child: Text('OK'.tr),
        ),
      ],
    );
  }
}
