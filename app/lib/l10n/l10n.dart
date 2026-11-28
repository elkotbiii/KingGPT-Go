// The one import for UI text: `import '../../l10n/l10n.dart';`
//
//  - In widgets: `context.l10n.chatComposerHint`.
//  - Without a BuildContext (state, services, error mapping): `appL10n.xxx`,
//    which always follows the language the app is showing.
//
// Strings live in lib/l10n/parts/<area>_{zh,en}.arb; tool/l10n_merge.py
// merges them and regenerates lib/l10n/gen/.

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Some things are called something else on iOS: 「文件」, not 「下载」.
bool get wordsForIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// The language the app shows: what [AppLocale.resolve] picked from the
/// user's choice and the system languages.
abstract final class AppLocale {
  static const ar = Locale('ar');
  static const zhCN = Locale('zh', 'CN');
  static const en = Locale('en');

  /// Arabic is the default UI locale. zh_CN remains temporarily available for
  /// the existing generated catalog and Chinese-content glyph selection;
  /// it is not offered in the language picker and is removed in the catalog migration.
  static const supported = [ar, zhCN, en];

  static Locale _locale = ar;
  static L10n _l10n = lookupL10n(ar);

  /// The locale in use (Arabic until the app resolves a saved or system choice).
  static Locale get current => _locale;

  static bool get isEnglish => _locale.languageCode == 'en';

  static L10n get l10n => _l10n;

  /// Switches [appL10n] to [locale].
  static void use(Locale locale) {
    final next = switch (locale.languageCode) {
      'en' => en,
      'zh' => zhCN, // Temporary compatibility for existing Chinese catalog users/tests.
      _ => ar,
    };
    if (next == _locale) return;
    _locale = next;
    _l10n = lookupL10n(next);
  }

  /// Prefer a supported user choice or system language; otherwise use Arabic.
  /// Chinese remains recognized only for explicit internal compatibility, not
  /// as a system-language fallback or a user-selectable app language.
  static Locale resolve(Locale? chosen, List<Locale>? system) {
    if (chosen != null) {
      return switch (chosen.languageCode) {
        'en' => en,
        'zh' => zhCN,
        _ => ar,
      };
    }
    for (final l in system ?? const <Locale>[]) {
      if (l.languageCode == 'ar') return ar;
      if (l.languageCode == 'en') return en;
    }
    return ar;
  }
}

/// UI text for code without a BuildContext. Follows the app language.
L10n get appL10n => AppLocale.l10n;

extension L10nContext on BuildContext {
  /// UI text in the app language. Falls back to [appL10n] where the tree has
  /// no L10n delegate (bare MaterialApps in tests).
  L10n get l10n => Localizations.of<L10n>(this, L10n) ?? AppLocale.l10n;
}

extension L10nFormat on L10n {
  /// 「3月5日」/「Mar 5」.
  String monthDay(DateTime d) => commonMonthDay('${d.month}', d.day);
}
