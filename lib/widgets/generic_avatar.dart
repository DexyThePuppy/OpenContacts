import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_contacts/auxiliary.dart';

class GenericAvatar extends StatelessWidget {
  const GenericAvatar({
    this.userId,
    this.imageUri = '',
    this.radius = 20,
    this.placeholderIcon,
    this.foregroundColor,
    super.key,
  });

  final String? userId;
  final String imageUri;
  final double radius;
  final IconData? placeholderIcon;
  final Color? foregroundColor;

  /// Get the best image provider based on cache availability
  Future<ImageProvider> _getImageProvider() async {
    if (userId != null) {
      return await Aux.getProfileImageProvider(null, userId: userId);
    }
    return NetworkImage(imageUri);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: _getImageProvider(),
      builder: (context, snapshot) {
        final provider = snapshot.data;
        DecorationImage? image;
        if (provider != null) {
          image = DecorationImage(
            image: provider,
            fit: BoxFit.cover,
            onError: (_, __) {},
          );
        }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius * 0.5),
            image: image,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
          child: (image == null || placeholderIcon != null)
          ? Center(
              child: Icon(
                placeholderIcon ?? Icons.person,
                size: radius,
                color: foregroundColor ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
        );
      },
    );
  }
}
