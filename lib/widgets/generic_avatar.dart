import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GenericAvatar extends StatelessWidget {
  const GenericAvatar({
    required this.imageUri,
    this.radius = 20,
    this.placeholderIcon = Icons.person,
    this.foregroundColor,
    this.fit,
    super.key,
  });

  final String? imageUri;
  final double? radius;
  final IconData placeholderIcon;
  final Color? foregroundColor;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return imageUri == null
        ? CircleAvatar(
            radius: radius,
            child: Icon(placeholderIcon),
          )
        : CachedNetworkImage(
            imageUrl: imageUri!,
            imageBuilder: (context, imageProvider) => radius != null
                ? CircleAvatar(
                    radius: radius,
                    backgroundImage: imageProvider,
                  )
                : Image(
                    image: imageProvider,
                    fit: fit ?? BoxFit.cover,
                  ),
            errorWidget: (context, url, error) {
              print("🐾 DEBUG: Image load error for URL: $url");
              print("🐾 DEBUG: Error details: $error");
              return CircleAvatar(
                radius: radius,
                child: Icon(
                  Icons.broken_image,
                  color: foregroundColor,
                ),
              );
            },
            placeholder: (context, child) => CircleAvatar(
              radius: radius,
              child: const CircularProgressIndicator(),
            ),
          );
  }
}