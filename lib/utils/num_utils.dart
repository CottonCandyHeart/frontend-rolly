
import 'package:frontend_rolly/lang/app_language.dart';

class NumUtils {

  static int getMETS(String? action, AppLanguage lang){ 
    if (action == lang.t('opt1')){
      return 6;
    } else if (action == lang.t('opt2')) {
      return 8;
    } else if (action == lang.t('opt3')) {
      return 5;
    } else if (action == lang.t('opt4')) {
      return 9;
    }

    return 0;
  }

  int countCalories(String? activity, double? weight, Duration duration, AppLanguage lang) { 
    final int METS = getMETS(activity, lang);
    final double hours = duration.inSeconds / 3600;
    final double calories = METS * weight! * hours;

    return calories.round(); 
  }
}
