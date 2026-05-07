import 'package:flutter/material.dart';

import '../../../domain/settings/app_settings.dart';
import '../../settings/settings_controller.dart';
import '../../sharing/sharing_delivery_controller.dart';
import '../shell_chrome.dart';

class SharingSettingsPage extends StatelessWidget {
  const SharingSettingsPage({
    required this.controller,
    required this.deliveryController,
    super.key,
  });

  final SettingsController controller;
  final SharingDeliveryController deliveryController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = state.settings;
        final sharing = settings.sharing;

        return AdminPage(
          title: 'Sharing Settings',
          subtitle: 'Configure QR, local save, mail and SMS delivery.',
          children: [
            AdminPanel(
              title: 'Sharing Options',
              child: Wrap(
                spacing: 42,
                children: [
                  OptionSwitch(
                    label: 'Mail',
                    value: sharing.mailEnabled,
                    onChanged: (value) =>
                        _update(settings, sharing.copyWith(mailEnabled: value)),
                  ),
                  OptionSwitch(
                    label: 'SMS',
                    value: sharing.smsEnabled,
                    onChanged: (value) =>
                        _update(settings, sharing.copyWith(smsEnabled: value)),
                  ),
                  OptionSwitch(
                    label: 'QR',
                    value: sharing.qrEnabled,
                    onChanged: (value) =>
                        _update(settings, sharing.copyWith(qrEnabled: value)),
                  ),
                  OptionSwitch(
                    label: 'Save To PC',
                    value: sharing.saveToPcEnabled,
                    onChanged: (value) => _update(
                      settings,
                      sharing.copyWith(saveToPcEnabled: value),
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Mail Settings',
              child: ValueListenableBuilder<SharingDeliveryState>(
                valueListenable: deliveryController,
                builder: (context, deliveryState, _) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Sender Mail Address',
                              value: sharing.senderEmail,
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(senderEmail: value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 80),
                          Expanded(
                            child: _Field(
                              label: 'Sender Mail Password',
                              value: sharing.senderPassword,
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(senderPassword: value),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Mail Body',
                              value: sharing.mailBody,
                              hint: 'Your media is here',
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(mailBody: value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 80),
                          Expanded(
                            child: _Field(
                              label: 'Subject',
                              value: sharing.mailSubject,
                              hint: 'Your media booth share',
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(mailSubject: value),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Sender Host',
                              value: sharing.smtpHost,
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(smtpHost: value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 80),
                          Expanded(
                            child: _Field(
                              label: 'Sender Port',
                              value: sharing.smtpPort.toString(),
                              hint: '587',
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(
                                  smtpPort:
                                      int.tryParse(value) ?? sharing.smtpPort,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Receiver Mail Address',
                              value: sharing.receiverEmail,
                              onChanged: (value) => _update(
                                settings,
                                sharing.copyWith(receiverEmail: value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed:
                                sharing.mailEnabled &&
                                    !deliveryState.isSendingMail
                                ? () =>
                                      deliveryController.sendTestEmail(sharing)
                                : null,
                            child: deliveryState.isSendingMail
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Test Mail'),
                          ),
                          const Spacer(),
                        ],
                      ),
                      if (deliveryState.message != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(deliveryState.message!),
                        ),
                      ],
                      if (deliveryState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            deliveryState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            AdminPanel(
              title: 'SMS Settings',
              child: ValueListenableBuilder<SharingDeliveryState>(
                valueListenable: deliveryController,
                builder: (context, deliveryState, _) {
                  return Column(
                    children: [
                      _SmsField(
                        label: 'SMS Auth Token',
                        value: sharing.smsAuthToken,
                        onChanged: (value) => _update(
                          settings,
                          sharing.copyWith(smsAuthToken: value),
                        ),
                      ),
                      _SmsField(
                        label: 'SMS SID',
                        value: sharing.smsSid,
                        onChanged: (value) =>
                            _update(settings, sharing.copyWith(smsSid: value)),
                      ),
                      _SmsField(
                        label: 'SMS Host Phone Number',
                        value: sharing.smsFromNumber,
                        onChanged: (value) => _update(
                          settings,
                          sharing.copyWith(smsFromNumber: value),
                        ),
                      ),
                      _SmsField(
                        label: 'SMS Test Phone Number',
                        value: sharing.smsTestNumber,
                        onChanged: (value) => _update(
                          settings,
                          sharing.copyWith(smsTestNumber: value),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed:
                              sharing.smsEnabled && !deliveryState.isSendingSms
                              ? () => deliveryController.sendTestSms(sharing)
                              : null,
                          child: deliveryState.isSendingSms
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Test SMS'),
                        ),
                      ),
                      if (deliveryState.message != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(deliveryState.message!),
                        ),
                      ],
                      if (deliveryState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            deliveryState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _update(AppSettings settings, SharingSettings sharing) {
    controller.update(settings.copyWith(sharing: sharing));
  }
}

class _SmsField extends StatelessWidget {
  const _SmsField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: _Field(label: label, value: value, onChanged: onChanged),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.info_outline, size: 18, color: Colors.black45),
          const SizedBox(width: 260),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.hint = '',
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String value;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label),
        CompactInput(
          initialValue: value,
          hint: hint,
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
