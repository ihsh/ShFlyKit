#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/AMapNavi/AMapNaviKit.framework/AMapNavi.bundle"
  install_resource "${PODS_ROOT}/AMapNavi/AMapNaviKit.framework/AMap.bundle"
  install_resource "${PODS_ROOT}/GT3Captcha/ios/GT3Captcha.bundle"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-input-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-input@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-tab-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-tab@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-button-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-button@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-camera-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-camera@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-music-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-music@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-place-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-place@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-sleep-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-sleep@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-thought-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-thought@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_back@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_back@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_close@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_close@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_more@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_more@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_available@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_selected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_sold@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine1.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine2.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine3.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_snow.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_sunnySun.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_sunnySunshine.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_0.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_1.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_10.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_11.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_12.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_2.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_3.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_4.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_5.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_6.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_7.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_8.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_9.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/line.plist"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/piggy.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/rain.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/red_paceket@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/shenzhen.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/ball@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/camera@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/car2@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/car@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_bad.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_gray.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_green.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_no.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_serious.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_slow.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpsnormal@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpsnormal@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpssearchbutton@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpssearchbutton@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/locate_btn.jpg"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location _drop_blue@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_end@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_point@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_point@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_start@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/redPin@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/redPin@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/street_location@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/street_location@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/trackingPoints@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/userPosition.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/userPosition@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/wateRedBlank@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/wateRedBlank@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/icon_attention@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/icon_attention@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_arrow_right_gray@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_arrow_right_gray@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_diselected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_diselected@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_alipay_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_alipay_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_applepay@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_applepay@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_arrow_adown@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_arrow_adown@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_cash_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_cash_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wallet_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wallet_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wechat_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wechat_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_yunquickpass@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_yunquickpass@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_quickpass@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_quickpass@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_selected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_selected@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_yinlian@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_yinlian@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/navi_close_ex@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/navi_close_ex@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_qq.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_qzone.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_sina.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_sms.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat_favorite.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat_timeline.png"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/AMapNavi/AMapNaviKit.framework/AMapNavi.bundle"
  install_resource "${PODS_ROOT}/AMapNavi/AMapNaviKit.framework/AMap.bundle"
  install_resource "${PODS_ROOT}/GT3Captcha/ios/GT3Captcha.bundle"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-input-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-input@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-tab-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-button-tab@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-button-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-button@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-camera-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-camera@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-music-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-music@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-place-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-place@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-sleep-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-sleep@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-thought-highlighted@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/chooser-moment-icon-thought@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_back@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_back@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_close@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_close@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_more@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/ic_navbar_more@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_available@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_selected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Components/seat_sold@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine1.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine2.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_rainLine3.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_snow.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_sunnySun.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_sunnySunshine.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_0.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_1.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_10.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_11.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_12.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_2.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_3.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_4.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_5.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_6.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_7.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_8.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/ele_white_cloud_9.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/line.plist"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/piggy.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/rain.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/red_paceket@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Graphics/shenzhen.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/ball@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/camera@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/car2@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/car@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_bad.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_gray.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_green.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_no.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_serious.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/custtexture_slow.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpsnormal@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpsnormal@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpssearchbutton@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/gpssearchbutton@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/locate_btn.jpg"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location _drop_blue@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_end@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_point@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_point@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/location_start@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/redPin@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/redPin@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/street_location@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/street_location@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/trackingPoints@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/userPosition.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/userPosition@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/wateRedBlank@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Map/wateRedBlank@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/icon_attention@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/icon_attention@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_arrow_right_gray@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_arrow_right_gray@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_diselected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_diselected@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_alipay_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_alipay_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_applepay@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_applepay@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_arrow_adown@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_arrow_adown@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_cash_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_cash_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wallet_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wallet_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wechat_on@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_wechat_on@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_yunquickpass@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_payment_yunquickpass@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_quickpass@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_quickpass@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_selected@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_selected@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_yinlian@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/ic_yinlian@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/navi_close_ex@2x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Pay/navi_close_ex@3x.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_qq.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_qzone.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_sina.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_sms.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat_favorite.png"
  install_resource "${PODS_ROOT}/../../ShFlyKit/Assets/Share/share_wechat_timeline.png"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
