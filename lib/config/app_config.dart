class AppConfig {
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String recipientName = String.fromEnvironment(
    'RECIPIENT_NAME',
    defaultValue: 'Mrunali',
  );

  static const String giftOccasion = String.fromEnvironment(
    'GIFT_OCCASION',
    defaultValue: 'Happy Birthday',
  );

  static bool get isPersonalized => recipientName.trim().isNotEmpty;
}
