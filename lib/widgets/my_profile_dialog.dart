import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_contacts/apis/user_api.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/models/personal_profile.dart';
import 'package:open_contacts/widgets/default_error_widget.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/string_formatter.dart';
import 'dart:ui';
// import 'package:open_contacts/models/users/friend.dart';

class MyProfileDialog extends StatefulWidget {
  const MyProfileDialog({super.key});

  @override
  State<MyProfileDialog> createState() => _MyProfileDialogState();
}

class _MyProfileDialogState extends State<MyProfileDialog> {
  ClientHolder? _clientHolder;
  Future<PersonalProfile>? _personalProfileFuture;
  Future<StorageQuota>? _storageQuotaFuture;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final clientHolder = ClientHolder.of(context);
    if (_clientHolder != clientHolder) {
      _clientHolder = clientHolder;
      final apiClient = _clientHolder!.apiClient;
      _personalProfileFuture = UserApi.getPersonalProfile(apiClient);
      _storageQuotaFuture = UserApi.getStorageQuota(apiClient);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    DateFormat dateFormat = DateFormat.yMMMd();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FutureBuilder(
        future: _personalProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profile = snapshot.data as PersonalProfile;
            return Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                children: [
                  // Blurred background image
                  if (profile.userProfile.iconUrl.isNotEmpty)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Image.network(
                            Aux.resdbToHttp(profile.userProfile.iconUrl),
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
                              imageUri: Aux.resdbToHttp(profile.userProfile.iconUrl),
                              radius: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormattedText(
                                    FormatNode.fromText(profile.username),
                                    style: tt.headlineSmall?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    profile.email,
                                    style: tt.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        
                        // User info section
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow("User ID", profile.id, colorScheme, tt),
                              const SizedBox(height: 12),
                              _buildInfoRow("2FA", profile.twoFactor ? "Enabled" : "Disabled", colorScheme, tt),
                              const SizedBox(height: 12),
                              _buildInfoRow("Patreon Supporter", profile.isPatreonSupporter ? "Yes" : "No", colorScheme, tt),
                              const SizedBox(height: 12),
                              _buildInfoRow("Registration Date", dateFormat.format(profile.registrationDate), colorScheme, tt),
                              if (profile.publicBanExpiration?.isAfter(DateTime.now()) ?? false) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow("Ban Expiration", dateFormat.format(profile.publicBanExpiration!), colorScheme, tt),
                              ],
                            ],
                          ),
                        ),

                        // Storage section
                        const SizedBox(height: 24),
                        FutureBuilder(
                          future: _storageQuotaFuture,
                          builder: (context, snapshot) {
                            final storage = snapshot.data;
                            return Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: StorageIndicator(
                                usedBytes: storage?.usedBytes ?? 0,
                                maxBytes: storage?.fullQuotaBytes ?? 1,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return DefaultErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _personalProfileFuture = UserApi.getPersonalProfile(ClientHolder.of(context).apiClient);
                });
              },
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class StorageIndicator extends StatelessWidget {
  const StorageIndicator({required this.usedBytes, required this.maxBytes, super.key});

  final int usedBytes;
  final int maxBytes;

  @override
  Widget build(BuildContext context) {
    final value = usedBytes / maxBytes;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Storage:", style: Theme.of(context).textTheme.titleMedium),
              Text(// Displayed in GiB instead of GB for consistency with Resonite
                  "${(usedBytes * 9.3132257461548e-10).toStringAsFixed(2)}/${(maxBytes * 9.3132257461548e-10).toStringAsFixed(2)} GB"),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 12,
              color: value > 0.95 ? Theme.of(context).colorScheme.error : null,
              value: value,
            ),
          )
        ],
      ),
    );
  }
}
