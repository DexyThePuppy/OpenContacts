import 'package:flutter/material.dart';
import 'package:open_contacts/models/records/record.dart';

class PathItemListTile extends StatefulWidget {
  final Record record;
  final bool isSelected;
  final bool isAnySelected;
  final VoidCallback onSelect;
  final VoidCallback onNavigate;

  const PathItemListTile({
    required this.record,
    required this.isSelected,
    required this.isAnySelected,
    required this.onSelect,
    required this.onNavigate,
    super.key,
  });

  @override
  State<PathItemListTile> createState() => _PathItemListTileState();
}

class _PathItemListTileState extends State<PathItemListTile> {
  bool isHovered = false;
  Offset? mousePosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDirectory = widget.record.recordType == RecordType.directory;
    final iconColor = isDirectory ? Colors.amber : Colors.lightBlue;
    final icon = isDirectory ? Icons.folder : Icons.link;

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
                      child: Container(
                        color: iconColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: widget.isAnySelected ? widget.onSelect : widget.onNavigate,
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
                      leading: Icon(
                        icon,
                        size: 28,
                        color: iconColor,
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
                        "Created: ${widget.record.creationTime.toLocal().toString().split('.')[0]}",
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