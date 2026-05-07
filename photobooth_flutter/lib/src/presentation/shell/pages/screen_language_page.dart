import 'package:flutter/material.dart';

import '../../../domain/settings/app_settings.dart';
import '../../settings/settings_controller.dart';
import '../shell_chrome.dart';

class ScreenLanguagePage extends StatelessWidget {
  const ScreenLanguagePage({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = state.settings;
        final texts = settings.screenTexts;

        return AdminPage(
          title: 'Screen Language Settings',
          subtitle:
              'Customize guest-facing booth labels. Changes are saved immediately.',
          children: [
            AdminPanel(
              title: 'Booth Texts',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Fields(
                      fields: _leftFields,
                      texts: texts,
                      onChanged: (key, value) => _update(settings, key, value),
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: _Fields(
                      fields: _rightFields,
                      texts: texts,
                      onChanged: (key, value) => _update(settings, key, value),
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Language Tools',
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => controller.update(
                      settings.copyWith(
                        screenTexts: const ScreenTextSettings(),
                      ),
                    ),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset To English'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => controller.update(
                      settings.copyWith(
                        screenTexts: texts.copyWithValues(_russianPreset),
                      ),
                    ),
                    icon: const Icon(Icons.translate),
                    label: const Text('Russian Preset'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _update(AppSettings settings, String key, String value) {
    controller.update(
      settings.copyWith(
        screenTexts: settings.screenTexts.copyWithValue(key, value),
      ),
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({
    required this.fields,
    required this.texts,
    required this.onChanged,
  });

  final List<_LanguageField> fields;
  final ScreenTextSettings texts;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldLabel(field.label),
                CompactInput(
                  initialValue: texts.text(field.key),
                  onChanged: (value) => onChanged(field.key, value),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LanguageField {
  const _LanguageField(this.key, this.label);

  final String key;
  final String label;
}

const _leftFields = [
  _LanguageField('photo', 'Photo'),
  _LanguageField('startSession', 'Start Session'),
  _LanguageField('sessionComplete', 'Session Complete'),
  _LanguageField('done', 'Done'),
  _LanguageField('print', 'Print'),
  _LanguageField('printCollage', 'Print Collage'),
  _LanguageField('printing', 'Printing'),
  _LanguageField('close', 'Close'),
  _LanguageField('gallery', 'Gallery'),
  _LanguageField('photoItem', 'Photo Item'),
];

const _rightFields = [
  _LanguageField('video', 'Video'),
  _LanguageField('cancel', 'Cancel'),
  _LanguageField('buildCollage', 'Build Collage'),
  _LanguageField('collageReady', 'Collage Ready'),
  _LanguageField('collage', 'Collage'),
  _LanguageField('downloadLink', 'Download Link'),
  _LanguageField('emailCollage', 'Email Collage'),
  _LanguageField('sendingEmail', 'Sending Email'),
  _LanguageField('smsLink', 'SMS Link'),
  _LanguageField('sendingSms', 'Sending SMS'),
  _LanguageField('qrPreparing', 'QR Preparing Text'),
  _LanguageField('qrShow', 'QR Show Text'),
  _LanguageField('printingDisabled', 'Printing Disabled'),
  _LanguageField('selectPrinter', 'Select Printer Warning'),
  _LanguageField('emailDisabled', 'Email Disabled'),
  _LanguageField('emailMissingReceiver', 'Email Receiver Warning'),
  _LanguageField('smsDisabled', 'SMS Disabled'),
  _LanguageField('smsMissingReceiver', 'SMS Receiver Warning'),
];

const _russianPreset = {
  'photo': 'Фото',
  'video': 'Видео',
  'done': 'Готово',
  'cancel': 'Отмена',
  'gallery': 'Галерея',
  'print': 'Печать',
  'close': 'Закрыть',
  'email': 'E-mail',
  'qrPreparing': 'Готовим ссылку для скачивания',
  'qrShow': 'Отсканируйте QR-код для скачивания',
  'startSession': 'Начать съемку',
  'sessionComplete': 'Съемка завершена',
  'buildCollage': 'Собрать коллаж',
  'collageReady': 'Коллаж готов',
  'collage': 'Коллаж',
  'downloadLink': 'Ссылка для скачивания',
  'emailCollage': 'Отправить на email',
  'sendingEmail': 'Отправка email...',
  'emailDisabled': 'Email отключен в настройках.',
  'emailMissingReceiver': 'Укажите email получателя в настройках.',
  'smsLink': 'Отправить SMS',
  'sendingSms': 'Отправка SMS...',
  'smsDisabled': 'SMS отключен в настройках.',
  'smsMissingReceiver': 'Укажите номер получателя SMS в настройках.',
  'printing': 'Печать...',
  'printCollage': 'Печать коллажа',
  'printingDisabled': 'Печать отключена в настройках.',
  'selectPrinter': 'Выберите принтер в настройках печати.',
  'photoItem': 'Фото',
};
