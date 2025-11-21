import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';

class SupportWidget extends StatefulWidget {
  const SupportWidget({super.key});

  @override
  State<SupportWidget> createState() => _SupportWidgetState();
}

class _SupportWidgetState extends State<SupportWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t('contactUs'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: lang.t('email'),
                labelStyle: TextStyle(color: AppColors.text,),
                filled: true,
                fillColor: AppColors.accent,
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return lang.t('emailRequired');
                }
                if (!value.contains("@")) {
                  return lang.t('wrongEmail');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Subject
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: lang.t('topic'),
                labelStyle: TextStyle(color: AppColors.text,),
                filled: true,
                fillColor: AppColors.accent,
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return lang.t('topicRequired');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Message
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: lang.t('message'),
                labelStyle: TextStyle(color: AppColors.text,),
                filled: true,
                fillColor: AppColors.accent,
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return lang.t('messageRequired');
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _sendForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _sending
                    ? const CircularProgressIndicator(
                        color: AppColors.background,
                      )
                    : Text(
                        lang.t('send'),
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendForm() async {
    if (!_formKey.currentState!.validate()) return;

    final lang = context.read<AppLanguage>();

    setState(() => _sending = true);

    await Future.delayed(const Duration(seconds: 1)); // sending symulation

    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.t('messageSent')),
      ),
    );

    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }
}
