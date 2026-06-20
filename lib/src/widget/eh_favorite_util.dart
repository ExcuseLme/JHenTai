import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/exception/eh_site_exception.dart';
import 'package:jhentai/src/extension/dio_exception_extension.dart';
import 'package:jhentai/src/model/gallery.dart';
import 'package:jhentai/src/model/gallery_note.dart';
import 'package:jhentai/src/network/eh_request.dart';
import 'package:jhentai/src/setting/favorite_setting.dart';
import 'package:jhentai/src/setting/preference_setting.dart';
import 'package:jhentai/src/setting/user_setting.dart';
import 'package:jhentai/src/utils/eh_spider_parser.dart';
import 'package:jhentai/src/utils/snack_util.dart';
import 'package:jhentai/src/utils/toast_util.dart';
import 'package:jhentai/src/widget/eh_favorite_dialog.dart';

import '../service/log.dart';

bool _favoriteLoading = false;

/// 等效于详情页 handleTapFavorite：点击页码 → 收藏/取消收藏
Future<void> tapFavoriteOnCard(Gallery gallery) async {
  if (!userSetting.hasLoggedIn()) {
    toast('needLoginToOperate'.tr);
    return;
  }

  if (_favoriteLoading) {
    return;
  }
  _favoriteLoading = true;

  try {
    int? currentFavIndex = gallery.favoriteTagIndex;

    if (preferenceSetting.enableDefaultFavorite.isTrue &&
        userSetting.defaultFavoriteIndex.value != null) {
      int defaultIndex = userSetting.defaultFavoriteIndex.value!;

      if (currentFavIndex == defaultIndex) {
        await _removeFavoriteOnCard(gallery, currentFavIndex);
      } else {
        await _addFavoriteOnCard(gallery, currentFavIndex, defaultIndex, '');
      }
    } else {
      ({bool isDelete, int favIndex, String note, bool remember})? result = await Get.dialog(
        EHFavoriteDialog(
          selectedIndex: currentFavIndex,
          needInitNote: currentFavIndex != null,
          initNoteFuture: () => ehRequest.requestPopupPage<GalleryNote>(
            gallery.gid,
            gallery.token,
            'addfav',
            EHSpiderParser.favoritePopup2GalleryNote,
          ),
        ),
      );

      if (result == null) {
        _favoriteLoading = false;
        return;
      }

      if (result.isDelete) {
        await _removeFavoriteOnCard(gallery, currentFavIndex);
      } else {
        await _addFavoriteOnCard(gallery, currentFavIndex, result.favIndex, result.note);
      }
    }
  } on DioException catch (e) {
    log.error('favoriteGalleryFailed'.tr, e.errorMsg);
    snack('favoriteGalleryFailed'.tr, e.errorMsg ?? '', isShort: true);
  } on EHSiteException catch (e) {
    log.error('favoriteGalleryFailed'.tr, e.message);
    snack('favoriteGalleryFailed'.tr, e.message, isShort: true);
  } catch (e, s) {
    log.error('favoriteGalleryFailed'.tr, e, s);
    snack('favoriteGalleryFailed'.tr, e.toString(), isShort: true);
  } finally {
    _favoriteLoading = false;
  }
}

/// 等效于详情页 handleLongPressFavorite：长按页码 → 已收藏则取消，否则弹出选择框
Future<void> longPressFavoriteOnCard(Gallery gallery) async {
  if (!userSetting.hasLoggedIn()) {
    toast('needLoginToOperate'.tr);
    return;
  }

  if (_favoriteLoading) {
    return;
  }
  _favoriteLoading = true;

  try {
    int? currentFavIndex = gallery.favoriteTagIndex;

    if (currentFavIndex != null) {
      await _removeFavoriteOnCard(gallery, currentFavIndex);
    } else {
      _favoriteLoading = false;
      await tapFavoriteOnCard(gallery);
      return;
    }
  } on DioException catch (e) {
    log.error('removeFavoriteFailed'.tr, e.errorMsg);
    snack('removeFavoriteFailed'.tr, e.errorMsg ?? '', isShort: true);
  } on EHSiteException catch (e) {
    log.error('removeFavoriteFailed'.tr, e.message);
    snack('removeFavoriteFailed'.tr, e.message, isShort: true);
  } catch (e, s) {
    log.error('removeFavoriteFailed'.tr, e, s);
    snack('removeFavoriteFailed'.tr, e.toString(), isShort: true);
  } finally {
    _favoriteLoading = false;
  }
}

Future<void> _addFavoriteOnCard(Gallery gallery, int? currentFavIndex, int newFavIndex, String note) async {
  log.info('Favorite gallery from card: ${gallery.gid}');
  await ehRequest.requestAddFavorite(gallery.gid, gallery.token, newFavIndex, note);
  favoriteSetting.incrementFavByIndex(newFavIndex);
  favoriteSetting.decrementFavByIndex(currentFavIndex);
  gallery.favoriteTagIndex = newFavIndex;
  gallery.favoriteTagName = favoriteSetting.favoriteTagNames[newFavIndex];
  toast('favoriteGallerySuccess'.tr, isCenter: false);
}

Future<void> _removeFavoriteOnCard(Gallery gallery, int? currentFavIndex) async {
  log.info('Remove favorite gallery from card: ${gallery.gid}');
  await ehRequest.requestRemoveFavorite(gallery.gid, gallery.token);
  favoriteSetting.decrementFavByIndex(currentFavIndex);
  gallery.favoriteTagIndex = null;
  gallery.favoriteTagName = null;
  toast('removeFavoriteSuccess'.tr, isCenter: false);
}
