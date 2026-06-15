class SignupFormatters {
  static const List<String> _commonDomains = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'live.com'
  ];

  static String? getEmailCorrection(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@')) return null;

    final parts = cleanEmail.split('@');
    if (parts.length < 2) return null;

    final inputDomain = parts.last;

    if (_commonDomains.contains(inputDomain)) {
      return null;
    }

    for (final domain in _commonDomains) {
      final distance = _calculateLevenshtein(inputDomain, domain);

      if (distance > 0 && distance <= 2) {
        return domain;
      }
    }

    return null;
  }

  static int _calculateLevenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((curr, next) => curr < next ? curr : next);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }
}
