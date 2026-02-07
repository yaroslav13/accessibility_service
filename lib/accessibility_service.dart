import 'dart:async';

import 'package:accessibility_service/accessibility_event.dart';
import 'package:flutter/services.dart';

final class AccessibilityService {
  AccessibilityService._();

  static final instance = AccessibilityService._();

  static const _channel = EventChannel('accessibility_service/announcement_state');

  StreamController<AccessibilityEvent>? _streamController;
  StreamSubscription<dynamic>? _eventChannelSubscription;

  StreamController<AccessibilityEvent> get _effectiveStreamController {
    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<AccessibilityEvent>.broadcast(
        onListen: _subscribeEventChannel,
        onCancel: _unsubscribeEventChannel,
      );
    }
    return _streamController!;
  }

  Stream<AccessibilityEvent> get announcementStateChanges {
    return _effectiveStreamController.stream;
  }

  void _subscribeEventChannel() {
    _eventChannelSubscription ??= _channel.receiveBroadcastStream().listen(
      (event) => _effectiveStreamController.add(AccessibilityAnnouncementCompleted()),
      onError: _effectiveStreamController.addError,
    );
  }

  void _unsubscribeEventChannel() {
    _eventChannelSubscription?.cancel();
    _eventChannelSubscription = null;
    _streamController?.close();
    _streamController = null;
  }
}
