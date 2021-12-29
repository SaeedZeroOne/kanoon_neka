class DNA {
  String createAnagram(String str) {
    String anagram = "";
    List<String> arr = str.trim().split(" ");

    for (String s in arr) {
      if (containsEnglish(s)) {
        String reversed = s.split('').reversed.join('');
        List characters = ['،', '.', ','];
        for (int i = 0; i < characters.length; i++)
          if (reversed.startsWith(characters[i]))
            reversed = reversed.substring(1) + characters[i];
        anagram += reversed + ' ';
      } else
        anagram += s + ' ';
    }
    return anagram;
  }

  bool validateNumber(String input) {
    if ('.'.allMatches(input).length > 1 ||
        (input.length == 1 && '.'.allMatches(input).length == 1))
      return false;
    else
      return true;
  }

  bool containsEnglish(String input) {
    RegExp regex = new RegExp('.*[a-zA-Z0-9]+.*');
    if (regex.hasMatch(input))
      return true;
    else
      return false;
  }

  bool isOnlyPersian(String input) {
    RegExp regex = new RegExp(r"^[\u0600-\u06FF\uFB8A\u067E\u0686\u06AF\s‌]+$");
    if (regex.hasMatch(input))
      return true;
    else
      return false;
  }

  double score(double ekh, double omu, double khales, double bazdeh) {
    if (ekh > 175)
      ekh = 175;

    if (omu > 100)
      omu = 100;

    if (khales > 16)
      khales = 16;

    double ekh100 = ekh * 100 * 4 / 175;
    double omu100 = omu * 100 * 1 / 100;
    double khales100 = khales * 100 * 2 / 16;
    double bazdeh100 = bazdeh * 1;
    double sabet = 2 * 100;
    return (omu100 + ekh100 + bazdeh100 + khales100 + sabet) * 9;
  }

  String persianMonth(int month)
  {
    switch (month) {
      case 1:
        return 'فروردین';
      case 2:
        return 'اردیبهشت';
      case 3:
        return 'خرداد';
      case 4:
        return 'تیر';
      case 5:
        return 'مرداد';
      case 6:
        return 'شهریور';
      case 7:
        return 'مهر';
      case 8:
        return 'آبان';
      case 9:
        return 'آذر';
      case 10:
        return 'دی';
      case 11:
        return 'بهمن';
      default:
        return 'اسفند';
    }
  }

  String removeTrailingZeros(double input) {
    return input == input.truncate()
        ? input.toInt().toString()
        : input.toString();
  }

  String justify(String input) {
    return '\u202E' + createAnagram(input);
  }
}
