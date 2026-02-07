import 'package:flutter/foundation.dart';

@immutable
sealed class AccessibilityEvent {
  const AccessibilityEvent();
}

final class AccessibilityAnnouncementCompleted extends AccessibilityEvent {
  const AccessibilityAnnouncementCompleted();
}
