import 'package:open_contacts/apis/contact_api.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/models/users/user.dart';
import 'package:open_contacts/widgets/generic_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserListTile extends StatefulWidget {
  const UserListTile(
      {required this.user,
      required this.isFriend,
      required this.onChanged,
      super.key});

  final User user;
  final bool isFriend;
  final Function()? onChanged;

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  final DateFormat _regDateFormat = DateFormat.yMMMMd('en_US');
  late bool _localAdded = widget.isFriend;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Draggable<User>(
      data: widget.user,
      feedback: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FutureBuilder<ImageProvider>(
          future: Aux.getProfileImageProvider(widget.user.userProfile, userId: widget.user.id),
          builder: (context, snapshot) {
            return GenericAvatar(
              userId: widget.user.id,
              imageUri: snapshot.hasData ? snapshot.data!.toString() : Aux.getProfileImageUrl(widget.user.userProfile),
            );
          },
        ),
      ),
      childWhenDragging: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        child: ListTile(
          leading: FutureBuilder<ImageProvider>(
            future: Aux.getProfileImageProvider(widget.user.userProfile, userId: widget.user.id),
            builder: (context, snapshot) {
              return GenericAvatar(
                userId: widget.user.id,
                imageUri: snapshot.hasData ? snapshot.data!.toString() : Aux.getProfileImageUrl(widget.user.userProfile),
              );
            },
          ),
          title: Text(
            widget.user.username,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
          ),
          subtitle: Text(
            _regDateFormat.format(widget.user.registrationDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
          ),
          trailing: IconButton.filledTonal(
            icon: Icon(_localAdded ? Icons.person_remove : Icons.person_add),
            onPressed: null,
          ),
        ),
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        child: ListTile(
          leading: FutureBuilder<ImageProvider>(
            future: Aux.getProfileImageProvider(widget.user.userProfile, userId: widget.user.id),
            builder: (context, snapshot) {
              return GenericAvatar(
                userId: widget.user.id,
                imageUri: snapshot.hasData ? snapshot.data!.toString() : Aux.getProfileImageUrl(widget.user.userProfile),
              );
            },
          ),
          title: Text(
            widget.user.username,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            _regDateFormat.format(widget.user.registrationDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: _loading
              ? const CircularProgressIndicator()
              : IconButton.filledTonal(
                  icon: Icon(
                      _localAdded ? Icons.person_remove : Icons.person_add),
                  onPressed: () async {
                    // Remove or comment out this block if you want the feature to work
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Sorry, this feature is unavailable."))
                    // );
                    // return;

                    setState(() {
                      _loading = true;
                    });
                    try {
                      if (_localAdded) {
                        await ContactApi.removeUserAsFriend(
                            ClientHolder.of(context).apiClient,
                            user: widget.user);
                      } else {
                        await ContactApi.addUserAsFriend(
                            ClientHolder.of(context).apiClient,
                            user: widget.user);
                      }
                      setState(() {
                        _loading = false;
                        _localAdded = !_localAdded;
                      });
                      widget.onChanged?.call();
                    } catch (e, s) {
                      FlutterError.reportError(
                          FlutterErrorDetails(exception: e, stack: s));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: Text(
                              "Something went wrong: $e",
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        _loading = false;
                      });
                      return;
                    }
                  },
                ),
        ),
      ),
    );
  }
}
