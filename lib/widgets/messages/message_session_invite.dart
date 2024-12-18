import 'dart:convert';

import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/message.dart';
import 'package:open_contacts/models/session.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:open_contacts/widgets/messages/message_state_indicator.dart';
import 'package:open_contacts/widgets/sessions/session_view.dart';
import 'package:flutter/material.dart';

class MessageSessionInvite extends StatelessWidget {
  const MessageSessionInvite({required this.message, this.foregroundColor, super.key});

  final Color? foregroundColor;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final sessionInfo = Session.fromMap(jsonDecode(message.content));
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SessionView(session: sessionInfo)));
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Container(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GenericAvatar(
                          imageUri: Aux.resdbToHttp(sessionInfo.thumbnailUrl),
                          placeholderIcon: Icons.no_photography,
                          foregroundColor: foregroundColor,
                        ),
                        const SizedBox(height: 4,),
                        Text("${sessionInfo.sessionUsers.length.toString().padLeft(2, "0")}/${sessionInfo.maxUsers.toString().padLeft(2, "0")}", style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: foregroundColor),)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FormattedText(sessionInfo.formattedName, maxLines: null, softWrap: true, textAlign: TextAlign.start, style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium?.copyWith(color: foregroundColor),),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hosted by ${sessionInfo.hostUsername}", overflow: TextOverflow.ellipsis, style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: foregroundColor?.withAlpha(150)),),
                  MessageStateIndicator(message: message, foregroundColor: foregroundColor,),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}