import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/users/friend.dart';
import 'package:open_contacts/models/users/user.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:logging/logging.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/string_formatter.dart';
import 'dart:convert';
import 'dart:ui';

final log = Logger('UserProfileDialog');

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({
    super.key, 
    this.friend,
    this.user,
    this.id,

  }) : assert(friend != null || user != null, 'Either friend or user must be provided');

  final Friend? friend;
  final User? user;
  final String? id;

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  DateTime? registrationDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRegistrationDate();
  }

  Future<void> _loadRegistrationDate() async {
    final displayUser = (widget.friend ?? widget.user!) as dynamic;
    final client = ClientHolder.of(context).apiClient;
    try {
      final response = await client.get("/users/${displayUser.id}");
      client.checkResponse(response);
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() => registrationDate = DateTime.parse(data['registrationDate']));
      }
    } catch (e) {
      log.warning('Failed to load registration date', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final displayUser = (widget.friend ?? widget.user!) as dynamic;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // Blurred background image
            if (displayUser.userProfile?.iconUrl != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Image.network(
                      Aux.resdbToHttp(displayUser.userProfile?.iconUrl),
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.1),
                    ),
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  Row(
                    children: [
                      GenericAvatar(
                        imageUri: Aux.resdbToHttp(displayUser.userProfile?.iconUrl),
                        radius: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormattedText(
                              FormatNode.fromText(displayUser.username),
                              style: tt.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // World status (if available)
                  if (widget.friend?.userStatus.currentSessionIndex != null &&
                      widget.friend!.userStatus.currentSessionIndex >= 0 &&
                      widget.friend!.userStatus.decodedSessions.isNotEmpty &&
                      widget.friend!.userStatus.decodedSessions[
                        widget.friend!.userStatus.currentSessionIndex
                      ].name.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormattedText(
                            FormatNode.fromText(widget.friend!.userStatus.decodedSessions[
                              widget.friend!.userStatus.currentSessionIndex
                            ].name),
                            style: tt.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.friend!.userStatus.decodedSessions[
                            widget.friend!.userStatus.currentSessionIndex
                          ].description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: FormattedText(
                                FormatNode.fromText(widget.friend!.userStatus.decodedSessions[
                                  widget.friend!.userStatus.currentSessionIndex
                                ].description),
                                style: tt.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  
                  // User info section
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          "User ID",
                          displayUser.id,
                          colorScheme,
                          tt,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          "Registered",
                          registrationDate != null 
                            ? DateFormat.yMMMd().format(registrationDate!)
                            : null,
                          colorScheme,
                          tt,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String? value,
    ColorScheme colorScheme,
    TextTheme tt,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        value != null
          ? Text(
              value,
              style: tt.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            )
          : CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
      ],
    );
  }
} 