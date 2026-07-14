class SettingsValidators {
  SettingsValidators._();

  static String? requiredName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Name is required.';
    }
    if (trimmed.length > 100) {
      return 'Name must not exceed 100 characters.';
    }
    return null;
  }

  static String? integerRange(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return '$label must be a whole number.';
    }
    if (parsed < min || parsed > max) {
      return '$label must be between $min and $max.';
    }
    return null;
  }

  static String? decimalRange(
    String? value, {
    required String label,
    required double min,
    required double max,
  }) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return '$label must be a number.';
    }
    if (parsed < min || parsed > max) {
      return '$label must be between ${_format(min)} and ${_format(max)}.';
    }
    return null;
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
