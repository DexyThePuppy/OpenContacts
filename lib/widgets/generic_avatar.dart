import 'package:flutter/material.dart';

class GenericAvatar extends StatelessWidget {
  const GenericAvatar({
    required this.imageUri,
    this.radius = 20,
    this.placeholderIcon,
    this.foregroundColor,
    super.key,
  });

  final String imageUri;
  final double radius;
  final IconData? placeholderIcon;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius * 0.5),
        image: imageUri.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUri),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Handle error silently
                },
              )
            : null,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: imageUri.isEmpty || placeholderIcon != null
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
  }
}
