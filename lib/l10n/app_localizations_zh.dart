// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '卡片AI';

  @override
  String get loginButton => '登录';

  @override
  String get signupButton => '注册';

  @override
  String get emailHint => '邮箱';

  @override
  String get passwordHint => '密码';

  @override
  String get cardScreenTitle => '我的卡片';

  @override
  String get settingsScreenTitle => '设置';

  @override
  String get spendScreenTitle => '消费';

  @override
  String get addCardButton => '添加卡片';

  @override
  String get cardNameHint => '卡片名称';

  @override
  String get cardUrlHint => '卡片信息网址';

  @override
  String get saveButton => '保存';

  @override
  String get editButton => '编辑';

  @override
  String get deleteButton => '删除';

  @override
  String get signOutButton => '退出登录';

  @override
  String get deleteAccountButton => '删除账户';

  @override
  String get languageSetting => '语言';

  @override
  String get downloadModelButton => '下载LLM模型';

  @override
  String get purchaseInfoHint => '输入消费详情（例如：\'星巴克咖啡\'）';

  @override
  String get getMatchButton => '获取最佳卡片匹配';

  @override
  String get modelNotDownloaded => 'LLM模型未下载。请前往设置下载。';

  @override
  String get goToSettingsButton => '前往设置';

  @override
  String get cancelButton => '取消';

  @override
  String get noCardsMessage => '尚未添加卡片。添加您的第一张卡片！';

  @override
  String get thinkingProcessTitle => '思考过程';

  @override
  String get okButton => '确定';
}
