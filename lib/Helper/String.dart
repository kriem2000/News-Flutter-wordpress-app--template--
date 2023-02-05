// ignore_for_file: non_constant_identifier_names

import 'Constant.dart';

//define all string here that used in json api

final String getUserSignUpApi = baseUrl + 'user_signup';
final String getNewsApi = baseUrl + 'get_news';
final String getNewsByCatApi = baseUrl + 'get_news_by_category';
final String getSettingApi = baseUrl + 'get_settings';
final String getCatApi = baseUrl + 'get_category';
final String getNewsByIdApi = baseUrl + 'get_news_by_id';
final String setBookmarkApi = baseUrl + 'set_bookmark';
final String getBookmarkApi = baseUrl + 'get_bookmark';
final String setCommentApi = baseUrl + 'set_comment';
final String getCommnetByNewsApi = baseUrl + 'get_comment_by_news';
final String getBreakingNewsApi = baseUrl + 'get_breaking_news';
final String setProfileApi = baseUrl + 'set_profile_image';
final String setUpdateProfileApi = baseUrl + 'update_profile';
final String setRegisterToken = baseUrl + 'register_token';
final String getNotificationApi = baseUrl + 'get_notification';
final String setUserCatApi = baseUrl + 'set_user_category';
final String getUserByIdApi = baseUrl + 'get_user_by_id';
final String getNewsByUserCatApi = baseUrl + 'get_news_by_user_category';
final String setCommentDeleteApi = baseUrl + 'delete_comment';
final String setLikesDislikesApi = baseUrl + 'set_like_dislike';
final String setFlagApi = baseUrl + 'set_flag';
final String getLiveStreamingApi = baseUrl + 'get_live_streaming';
final String getSubCategoryApi = baseUrl + 'get_subcategory_by_category';
final String setLikeDislikeComApi = baseUrl + 'set_comment_like_dislike';
final String getNewsByTagApi = baseUrl + 'get_news_by_tag';
final String getUserNotificationApi = baseUrl + 'get_user_notification';
final String updateFCMIdApi = baseUrl + 'update_fcm_id';
final String deleteUserNotiApi = baseUrl + 'delete_user_notification';
final String getQueApi = baseUrl + 'get_question';
final String getQueResultApi = baseUrl + 'get_question_result';
final String setQueResultApi = baseUrl + 'set_question_result';
final String userDeleteApi = baseUrl + 'delete_user';
final String getTagsApi = baseUrl + 'get_tag';
final String setNewsApi = baseUrl + 'set_news';
final String updateNewsApi = baseUrl + 'update_news';
final String setDeleteNewsApi = baseUrl + 'delete_news';
final String setDeleteImageApi = baseUrl + 'delete_news_images';

final String ISFIRSTTIME = 'loginfirst$appName';

const String ID = "id";
const String NAME = "name";
const String EMAIL = "email";
const String TYPE = "type";
const String URL = "url";
const String STATUS = "status";
const String FCM_ID = "fcm_id";
const String PROFILE = "profile";
const String ROLE = "role";
const String MOBILE = "mobile";
const String ACCESS_KEY = "access_key";
const String FIREBASE_ID = "firebase_id";
const String CATEGORY_ID = "category_id";
const String CONTENT_TYPE = "content_type";
const String SHOW_TILL = "show_till";
const String CONTENT_VALUE = "content_value";
const String DATE = "date";
const String TITLE = "title";
const String DESCRIPTION = "description";
const String IMAGE = "image";
const String CATEGORY_NAME = "category_name";
const String PRIVACY_POLICY = "privacy_policy";
const String CONTACT_US = "contact_us";
const String TERMS_CONDITIONS = "terms_conditions";
const String ABOUT_US = "about_us";
const String NEWS_ID = "news_id";
const String USER_ID = "user_id";
const String OFFSET = "offset";
const String LIMIT = "limit";
const String USER_NEWS = "get_user_news";
const String MESSAGE = "message";
const String COUNTER = "counter";
const String DATE_SENT = "date_sent";
const String SYSTEM = "system";
const String DARK = "Dark";
const String LIGHT = "light";
const String APP_THEME = "App Theme";
const String OTHER_IMAGE = "other_image";
const String OTHER_URL = "other_url";
const String IMAGE_DATA = "image_data";
const String cur_catId = "catId";
const String COMMENT_ID = "comment_id";
const String font_value = "fontValue";
const String TOTAL_LIKE = "total_like";
const String LIKE = "like";
const String LANGUAGE_CODE = 'languageCode';
const String login_email = "email";
const String login_gmail = "gmail";
const String login_fb = "fb";
const String login_apple = "apple";
const String login_mbl = "mobile";
const String TAG_NAME = "tag_name";
const String SUBCAT_NAME = "subcategory_name";
const String SUBCAT_ID = "subcategory_id";
const String DISLIKE = "dislike";
const String TOTAL_DISLIKE = "total_dislike";
const String PARENT_ID = "parent_id";
const String REPLY = "replay";
const String SEARCH = "search";
const String TAGNAME = "tag_name";
const String SUBCATEGORY = "subcategory";
const String TAG_ID = "tag_id";
const String NOTIENABLE = "notiEnabled";
const String HISTORY_LIST = "history_list";
const String QUESTION = "question";
const String QUESTION_ID = "question_id";
const String OPTION_ID = "option_id";
const String OPTION = "option";
const String OPTIONS = "options";
const String PERCENTAGE = "percentage";
const String CATEGORY_MODE = "category_mode";
const String BREAK_NEWS_MODE = "breaking_news_mode";
const String COMM_MODE = "comments_mode";
const String LIVE_STREAM_MODE = "live_streaming_mode";
const String SUBCAT_MODE = "subcategory_mode";
const String FB_REWARDED_ID = "fb_rewarded_video_id";
const String FB_INTER_ID = "fb_interstitial_id";
const String FB_BANNER_ID = "fb_banner_id";
const String FB_NATIVE_ID = "fb_native_unit_id";
const String IOS_FB_REWARDED_ID = "ios_fb_rewarded_video_id";
const String IOS_FB_INTER_ID = "ios_fb_interstitial_id";
const String IOS_FB_BANNER_ID = "ios_fb_banner_id";
const String IOS_FB_NATIVE_ID = "ios_fb_native_unit_id";

const String GO_REWARDED_ID = "google_rewarded_video_id";
const String GO_INTER_ID = "google_interstitial_id";
const String GO_BANNER_ID = "google_banner_id";
const String GO_NATIVE_ID = "google_native_unit_id";
const String IOS_GO_REWARDED_ID = "ios_google_rewarded_video_id";
const String IOS_GO_INTER_ID = "ios_google_interstitial_id";
const String IOS_GO_BANNER_ID = "ios_google_banner_id";
const String IOS_GO_NATIVE_ID = "ios_google_native_unit_id";
//add ads string for Unity ads
const String U_REWARDED_ID = "unity_rewarded_video_id";
const String U_INTER_ID = "unity_interstitial_id";
const String U_BANNER_ID = "unity_banner_id";
const String U_AND_GAME_ID = "android_game_id";
const String IOS_U_REWARDED_ID = "ios_unity_rewarded_video_id";
const String IOS_U_INTER_ID = "ios_unity_interstitial_id";
const String IOS_U_BANNER_ID = "ios_unity_banner_id";
const String IOS_U_GAME_ID = "ios_game_id";

const String ADS_MODE = "in_app_ads_mode";
const String IOS_ADS_MODE = "ios_in_app_ads_mode";
const String ADS_TYPE = "ads_type";
const String IOS_ADS_TYPE = "ios_ads_type";

//current user param
String CUR_USERID = '0';
String CUR_USERNAME = '';
String CUR_USEREMAIL = '';
String CATID = "";

String category_mode = '';
String comments_mode = '';
String breakingNews_mode = "";
String liveStreaming_mode = "";
String subCategory_mode = "";

String in_app_ads_mode = "";
String ios_in_app_ads_mode = "";

String ads_type = "";
String ios_ads_type = "";

String fbRewardedVideoId = "";
String fbInterstitialId = "";
String fbBannerId = "";
String fbNativeUnitId = "";
String iosFbRewardedVideoId = "";
String iosFbInterstitialId = "";
String iosFbBannerId = "";
String iosFbNativeUnitId = "";

String goRewardedVideoId = "";
String goInterstitialId = "";
String goBannerId = "";
String goNativeUnitId = "";
String iosGoRewardedVideoId = "";
String iosGoInterstitialId = "";
String iosGoBannerId = "";
String iosGoNativeUnitId = "";

String unityGameID = "";
String iosUnityGameID = "";

String unityRewardedVideoId = "";
String unityInterstitialId = "";
String unityBannerId = ""; //"News_Details_Banner_Ad"; //
String iosUnityRewardedVideoId = "";
String iosUnityInterstitialId = "";
String iosUnityBannerId = "";

String token1 = "";
bool? isDark;
bool? notiEnable;
double? deviceHeight;
double? deviceWidth;
