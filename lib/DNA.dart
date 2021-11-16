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

  double score(double ekh, double omu, double bazdeh) {
    double ekh100 = ekh * 100 * 12 / 175;
    double omu100 = ekh * 100 * 1 / 100;
    double bazdeh100 = bazdeh * 4;
    return (omu100 + ekh100 + bazdeh100) * 90 / 17;
  }
}
