import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/records/record.dart';

class ObjectItemListTile extends StatefulWidget {
  final Record record;
  final bool isSelected;
  final bool isAnySelected;
  final VoidCallback onSelect;
  final VoidCallback onOpen;

  const ObjectItemListTile({
    required this.record,
    required this.isSelected,
    required this.isAnySelected,
    required this.onSelect,
    required this.onOpen,
    super.key,
  });

  @override
  State<ObjectItemListTile> createState() => _ObjectItemListTileState();
}

class _ObjectItemListTileState extends State<ObjectItemListTile> {
  bool isHovered = false;
  Offset? mousePosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUri = Aux.resdbToHttp(widget.record.thumbnailUri);

    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onEnter: (event) {
          setState(() {
            mousePosition = event.localPosition;
            isHovered = true;
          });
        },
        onHover: (event) {
          setState(() {
            mousePosition = event.localPosition;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              if (mousePosition != null)
                Positioned.fromRect(
                  rect: Rect.fromLTWH(
                    8,
                    4,
                    constraints.maxWidth - 16,
                    56,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    opacity: isHovered ? 0.08 : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TweenAnimationBuilder<Alignment>(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        tween: Tween<Alignment>(
                          begin: mousePosition != null
                              ? Alignment(
                                  ((mousePosition!.dx / constraints.maxWidth) -
                                          0.5) *
                                      0.3,
                                  ((mousePosition!.dy / 54) - 0.5) * 0.3,
                                )
                              : Alignment.center,
                          end: Alignment.center,
                        ),
                        builder: (context, alignment, child) => FutureBuilder<ImageProvider>(
                          future: Aux.getProfileImageProvider(null, userId: null),
                          builder: (context, snapshot) {
                            final provider = snapshot.hasData 
                              ? snapshot.data! 
                              : NetworkImage(imageUri);
                            return Image(
                              image: provider,
                          fit: BoxFit.cover,
                          alignment: alignment,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(color: colorScheme.secondaryContainer),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: widget.isAnySelected ? widget.onSelect : widget.onOpen,
                onLongPress: widget.onSelect,
                onSecondaryTapUp: (_) => widget.onSelect(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Material(
                    color: widget.isSelected ? colorScheme.primaryContainer : 
                           isHovered ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : Colors.transparent,
                    elevation: widget.isSelected || isHovered ? 1 : 0,
                    shadowColor: colorScheme.shadow.withOpacity(0.5),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: (isHovered && !widget.isSelected) ? 
                             BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5) : 
                             BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                      dense: true,
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUri,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.record.formattedName.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "Owner: ${widget.record.ownerId}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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