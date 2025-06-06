import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/widgets/messages/message_asset.dart';
import 'package:open_contacts/widgets/messages/message_audio_player.dart';
import 'package:open_contacts/widgets/messages/message_session_invite.dart';
import 'package:open_contacts/widgets/messages/message_text.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.senderId == ClientHolder.of(context).apiClient.userId;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = mine ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    final backgroundColor = mine ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest ;
    return Padding(
      padding: EdgeInsets.only(left: mine ? 32 : 12, bottom: 16, right: mine ? 12 : 32),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Material(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: foregroundColor),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: switch (message.type) {
                MessageType.sessionInvite => MessageSessionInvite(message: message, foregroundColor: foregroundColor,),
                MessageType.object => MessageAsset(message: message, foregroundColor: foregroundColor,),
                MessageType.sound => MessageAudioPlayer(message: message, foregroundColor: foregroundColor,),
                MessageType.unknown || MessageType.text => MessageText(message: message, foregroundColor: foregroundColor,)
              },
            ),
          ),
        ],
      ),
    );
  }
}
