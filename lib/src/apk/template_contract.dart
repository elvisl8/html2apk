/// Constants shared between the template APK and the patcher.
const kTemplatePackage = 'de.devilapi.html2apk.template';
const kTemplateLabel = 'HTML2APK_TEMPLATE_LABEL';
const kTemplateVersionName = '1.0';
const kConfigPath = 'assets/config.json';
const kManifestPath = 'AndroidManifest.xml';

/// Prefix under which a local site's files are stored in the APK.
const kSitePathPrefix = 'assets/site/';
final kIconPath = RegExp(
  r'^res/mipmap-(mdpi|hdpi|xhdpi|xxhdpi|xxxhdpi)(-v4)?/ic_launcher\.png$',
);
const kIconSizes = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};
