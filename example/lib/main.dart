import 'dart:async';

import 'package:accessibility_service/accessibility_event.dart';
import 'package:accessibility_service/accessibility_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _accessibilityService = AccessibilityService.instance;

  int _announcementCompletedCount = 0;
  DateTime? _lastAnnouncementTime;
  StreamSubscription<AccessibilityEvent>? _announcementSubscription;
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _startListeningToAnnouncements();
  }

  @override
  void dispose() {
    _announcementSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToAnnouncements() {
    _announcementSubscription = _accessibilityService.announcementStateChanges.listen((event) {
      if (event is AccessibilityAnnouncementCompleted) {
        final now = DateTime.now();
        final timeString = '${now.hour}:${now.minute}:${now.second}.${now.millisecond}';

        setState(() {
          _announcementCompletedCount++;

          _eventLog.insert(0, '[$timeString] Announcement COMPLETED (#$_announcementCompletedCount)');

          // Calculate duration since last announcement if available
          if (_lastAnnouncementTime != null) {
            final duration = now.difference(_lastAnnouncementTime!);
            _eventLog.insert(0, '    Time since last: ${duration.inMilliseconds}ms');
          }

          _lastAnnouncementTime = now;

          if (_eventLog.length > 20) {
            _eventLog.removeRange(20, _eventLog.length);
          }
        });
      }
    });
  }

  void _triggerAccessibilityAnnouncement() {
    SemanticsService.sendAnnouncement(
      View.of(context),
      'This is a test accessibility announcement at ${DateTime.now().second} seconds',
      TextDirection.ltr,
    );
  }

  void _clearLog() {
    setState(() {
      _eventLog.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Accessibility Service Example'), backgroundColor: Colors.blue),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Announcement Statistics',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            const Text('Completed', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '$_announcementCompletedCount',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _triggerAccessibilityAnnouncement,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Test Announcement'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _clearLog,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Log
              Text('Event Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Expanded(
                child: Card(
                  child: _eventLog.isEmpty
                      ? const Center(
                          child: Text(
                            'No events yet.\nTap "Test Announcement" to trigger an accessibility announcement.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _eventLog.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                _eventLog[index],
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: _eventLog[index].contains('COMPLETED') ? Colors.blue[700] : Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
