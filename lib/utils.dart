import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

// #### dart ####

String? wrapWithQuote(String? text) {
  return text == null ? text : '"$text"';
}



// #### extension ####

extension LocaleExtension on Locale {
  String countryName(BuildContext context) {
    String codes = countryCode == null ? "ko_KR" : "${languageCode}_$countryCode";
    return LocaleNames.of(context)?.nameOf(codes) ?? "대한민국";
  }
}

extension DateTimeExtension on DateTime {
  String toServerFormatString({bool containDate = true, bool containTime = false}) {
    // 에뮬레이터에서 실행할 경우, DateTime객체는 local이 아닌 utc로 생성된다.
    return "${containDate ? "$year-${_padTime(month)}-${_padTime(day)}" : ""}${containDate && containTime ? " " : ""}${containTime ? "${_padTime(hour)}:${_padTime(minute)}:${_padTime(second)}" : ""}";//2022-04-10 23:10:11
  }

  String _padTime(int time) => time.toString().padLeft(2, "0");

  DateTime get startMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endMonth {
    return DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
  }

  int get days {
    if(month == 2) {
      return year % 400 == 0 || (year % 100 != 0 && year % 4 == 0) ? 29 : 28;
    }
    switch(month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      default:
        return 30;
    }
  }

  DateTime get maxTime {
    return DateTime(year, month, day).add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  }

  DateTime get minTime {
    return DateTime(year, month, day);
  }
}



// #### flutter ####

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child,
      ScrollableDetails details) {
    return child;
  }
}
