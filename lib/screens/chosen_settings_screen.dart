import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/widgets/about_us_widget.dart';
import 'package:frontend_rolly/widgets/change_email_widget.dart';
import 'package:frontend_rolly/widgets/change_passwd.dart';
import 'package:frontend_rolly/widgets/language_widget.dart';
import 'package:frontend_rolly/widgets/legal_information_widget.dart';
import 'package:frontend_rolly/widgets/notification_widget.dart';
import 'package:frontend_rolly/widgets/support_widget.dart';
import 'package:frontend_rolly/widgets/units_widget.dart';
import 'package:provider/provider.dart';

class ChosenSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ChosenSettingsScreen({
    super.key,
    required this.onBack,
    required this.pageNo,
  });

  final int pageNo;

  @override
  State<ChosenSettingsScreen> createState() => _ChosenSettingsState();
}



class _ChosenSettingsState extends State<ChosenSettingsScreen> {
  @override
  Widget build(BuildContext context) {

    final lang = context.read<AppLanguage>();

    final List<Widget> widgetOptions = <Widget>[
      NotificationWidget(),
      LanguageWidget(),
      UnitsWidget(),
      SupportWidget(),
      LegalInformationWidget(),
      AboutUsWidget(),
      ChangePasswdWidget(onBack: widget.onBack,),
      ChangeEmailWidget(onBack: widget.onBack,),
    ];

    int getIndex() {
      return widget.pageNo - 1;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
              Navigator.pop(context);
            },
          ),
          title: Text(lang.t('settings'), style: TextStyle(color: AppColors.text)),
        ),
        body: Center(
          //crossAxisAlignment: CrossAxisAlignment.start,
          child: widgetOptions.elementAt(getIndex()),
        ),
      ),
    );
  }
}