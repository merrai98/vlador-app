import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../../injection_container.dart';
import '../../constants/preferences_keys.dart';
import '../shared_preferences_manger.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit()
      : super(
          LanguageState(
            language: sl<SharedPreferencesService>()
                    .getData<String>(PreferencesKeys.language) ??
                ui.window.locale.languageCode,
          ),
        );

  void changeLanguage(BuildContext context, String newLanguage) async {
    await context.setLocale(Locale(newLanguage));
    await sl<SharedPreferencesService>().saveData(PreferencesKeys.language, newLanguage);
    emit(LanguageState(language: newLanguage));
  }
}
