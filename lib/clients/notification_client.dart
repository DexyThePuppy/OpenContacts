import 'dart:io';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:windows_notification/windows_notification.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/models/session.dart';

class NotificationChannel {
  final String id;
  final String name;
  final String description;

  const NotificationChannel({required this.name, required this.id, required this.description});
}

class NotificationClient {
  static const NotificationChannel _messageChannel = NotificationChannel(
    id: "messages",
    name: "Messages",
    description: "Messages received from your friends",
  );

  late final fln.FlutterLocalNotificationsPlugin _notifier;
  late final WindowsNotification? _winNotifier;

  NotificationClient() {
    _notifier = fln.FlutterLocalNotificationsPlugin();
    if (Platform.isWindows) {
      _winNotifier = WindowsNotification(
        applicationId: "OpenContacts.Dexy",
      );
    }
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notifier.initialize(
      const fln.InitializationSettings(
        android: fln.AndroidInitializationSettings("ic_notification"),
        iOS: fln.DarwinInitializationSettings(),
        macOS: fln.DarwinInitializationSettings(),
        linux: fln.LinuxInitializationSettings(defaultActionName: "Open OpenContacts"),
      ),
    );
  }

  Future<void> showUnreadMessagesNotification(Iterable<Message> messages) async {
    if (messages.isEmpty) return;

    final bySender = groupBy(messages, (p0) => p0.senderId);

    for (final entry in bySender.entries) {
      final uname = entry.key.stripUid();
      if (Platform.isWindows && _winNotifier != null) {
        for (final message in entry.value) {
          String content = _getMessageContent(message);
          await _winNotifier!.showNotification(
            title: uname,
            body: content,
          );
        }
      } else {
        await _notifier.show(
          uname.hashCode,
          null,
          null,
          fln.NotificationDetails(
            android: fln.AndroidNotificationDetails(
              _messageChannel.id,
              _messageChannel.name,
              channelDescription: _messageChannel.description,
              importance: fln.Importance.high,
              priority: fln.Priority.max,
              actions: [
                fln.AndroidNotificationAction(
                  'open_chat',
                  'Open Chat',
                  showsUserInterface: true,
                ),
              ],
              styleInformation: fln.MessagingStyleInformation(
                fln.Person(
                  name: uname,
                  bot: false,
                ),
                groupConversation: false,
                messages: entry.value.map((message) {
                  return fln.Message(
                    _getMessageContent(message),
                    message.sendTime.toLocal(),
                    fln.Person(
                      name: uname,
                      bot: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
    }
  }

  String _getMessageContent(Message message) {
    switch (message.type) {
      case MessageType.unknown:
        return "Unknown Message Type";
      case MessageType.text:
        return message.content;
      case MessageType.sound:
        return "Audio Message";
      case MessageType.sessionInvite:
        try {
          final session = Session.fromMap(jsonDecode(message.content));
          return "Session Invite to ${session.name}";
        } catch (_) {
          return "Session Invite";
        }
      case MessageType.object:
        return "Asset";
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (Platform.isWindows && _winNotifier != null) {
      await _winNotifier!.showNotification(
        title: title,
        body: body,
      );
    } else {
      await _notifier.show(
        0,  // notification id
        title,
        body,
        fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            _messageChannel.id,
            _messageChannel.name,
            channelDescription: _messageChannel.description,
            importance: fln.Importance.high,
            priority: fln.Priority.max,
          ),
        ),
      );
    }
  }
}

extension on WindowsNotification {
  showNotification({required String title, required String body}) {}
}
