import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import 'notify_state.dart';

/// 设置 → 语言.
enum AppLanguage {
  system,
  ar,
  zh,
  en;

  /// The fixed locale, or null to follow the system languages.
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.ar => AppLocale.ar,
    AppLanguage.zh => AppLocale.zhCN,
    AppLanguage.en => AppLocale.en,
  };

  static AppLanguage parse(String? v) {
    // Migrate an older saved Chinese choice to the new Arabic default.
    if (v == 'zh') return AppLanguage.ar;
    return AppLanguage.values.firstWhere((l) => l.name == v, orElse: () => AppLanguage.ar);
  }
}

class AppLanguageController extends Notifier<AppLanguage> {
  /// SharedPreferences key. The Android side reads it too (`flutter.app_language`,
  /// AppStrings.kt), so notifications follow the app, not the system.
  static const prefsKey = 'app_language';

  /// What the app starts with: [load] fills it in before runApp so the first
  /// frame is already in the chosen language. New installs start in Arabic.
  /// Tests may override this (test/flutter_test_config.dart).
  static AppLanguage initial = AppLanguage.ar;

  /// Reads the stored choice into [initial].
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      initial = AppLanguage.parse(prefs.getString(prefsKey));
    } catch (_) {
      // Unreadable prefs: keep the Arabic default.
    }
  }

  @override
  AppLanguage build() => initial;

  Future<void> set(AppLanguage language) async {
    if (language == state) return;
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, language.name);
    // Android re-registers the notification channels under the new language.
    unawaited(ref.read(notifyChannelProvider).status());
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageController, AppLanguage>(AppLanguageController.new);
