import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/models/records/record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../formatted_text.dart';

class ObjectInventoryTile extends StatelessWidget {
  ObjectInventoryTile({required this.record, this.onTap, this.onLongPress, this.selected=false, super.key});

  final bool selected;
  final Record record;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final DateFormat _dateFormat = DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: selected ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? colorScheme.primary.withOpacity(0.6) : colorScheme.outlineVariant.withOpacity(0.5),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withOpacity(0.1),
        highlightColor: colorScheme.primary.withOpacity(0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Hero(
                tag: record.id,
                child: CachedNetworkImage(
                  imageUrl: Aux.resdbToHttp(record.thumbnailUri),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 36,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  placeholder: (context, uri) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FormattedText(
                          record.formattedName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.1,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _dateFormat.format(record.creationTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
}
