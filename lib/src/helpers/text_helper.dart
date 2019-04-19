class TextHelper{
  bool isInvalidTextForItem(String text){
    RegExp exp = RegExp(r"^[A-Za-z0-9]*[A-Za-z][A-Za-z0-9 _]*$", caseSensitive: false, multiLine: false);
    final matches = exp.allMatches(text);
    for (Match match in matches){
      if(match.start == 0 && match.end == text.length){
        print(match.toString());
        return false;
      }
    }
    return true;
  }

  bool isInvalidTextForTag(String text){
    RegExp exp = RegExp(r"^[A-Za-z0-9]*[A-Za-z][A-Za-z0-9 ]*$", caseSensitive: false, multiLine: false);
    final matches = exp.allMatches(text);
    for (Match match in matches){
      if(match.start == 0 && match.end == text.length){
        print(match.toString());
        return false;
      }
    }
    return true;
  }

  bool isInvalidName(String text){
    RegExp exp = RegExp(r"^[A-Za-z]*[A-Za-z][A-Za-z ]*$", caseSensitive: false, multiLine: false);
    final matches = exp.allMatches(text);
    for (Match match in matches){
      if(match.start == 0 && match.end == text.length){
        print(match.toString());
        return false;
      }
    }
    return true;
  }
}