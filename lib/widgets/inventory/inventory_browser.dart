import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/clients/inventory_client.dart';
import 'package:open_contacts/models/inventory/resonite_directory.dart';
import 'package:open_contacts/models/records/record.dart';
import 'package:open_contacts/widgets/default_error_widget.dart';
import 'package:open_contacts/widgets/inventory/object_inventory_tile.dart';
import 'package:open_contacts/widgets/inventory/path_inventory_tile.dart';
import 'package:open_contacts/models/view_modes.dart';
import 'package:open_contacts/widgets/inventory/path_item_list_tile.dart';
import 'package:open_contacts/widgets/inventory/object_item_list_tile.dart';

class InventoryBrowser extends StatefulWidget {
  const InventoryBrowser({super.key});

  @override
  State<StatefulWidget> createState() => _InventoryBrowserState();
}

class _InventoryBrowserState extends State<InventoryBrowser> with AutomaticKeepAliveClientMixin {
  static const Duration _refreshLimit = Duration(seconds: 60);
  Timer? _refreshLimiter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final iClient = Provider.of<InventoryClient>(context, listen: false);
    if (iClient.directoryFuture == null) {
      iClient.loadInventoryRoot();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<InventoryClient>(builder: (BuildContext context, InventoryClient iClient, Widget? child) {
      return FutureBuilder<ResoniteDirectory>(
          future: iClient.directoryFuture,
          builder: (context, snapshot) {
            final currentDir = snapshot.data;
            return PopScope(
              canPop: currentDir?.isRoot ?? true,
              // ignore: deprecated_member_use
              onPopInvoked: (didPop) {
                if (!didPop) {
                  iClient.navigateUp();
                }
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_refreshLimiter?.isActive ?? false) return;
                  try {
                    await iClient.reloadCurrentDirectory();
                    _refreshLimiter = Timer(_refreshLimit, () {});
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Refresh failed: $e")));
                    }
                  }
                },
                child: Builder(
                  builder: (context) {
                    if (snapshot.hasError) {
                      FlutterError.reportError(
                          FlutterErrorDetails(exception: snapshot.error!, stack: snapshot.stackTrace));
                      return DefaultErrorWidget(
                        message: snapshot.error.toString(),
                        onRetry: () {
                          iClient.loadInventoryRoot();
                          iClient.forceNotify();
                        },
                      );
                    }
                    
                    final directory = snapshot.data;
                    final records = directory?.records ?? [];
                    records.sort(
                      (Record a, Record b) => iClient.sortMode.sortFunction(a, b, reverse: iClient.sortReverse),
                    );
                    final paths = records
                        .where((element) =>
                            element.recordType == RecordType.link || element.recordType == RecordType.directory)
                        .toList();
                    final objects = records
                        .where((element) =>
                            element.recordType != RecordType.link && element.recordType != RecordType.directory)
                        .toList();
                    final pathSegments = directory?.absolutePathSegments ?? [];
                    
                    return Stack(
                      children: [
                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              child: Wrap(
                                children: pathSegments
                                    .mapIndexed(
                                      (idx, segment) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (idx != 0) const Icon(Icons.chevron_right),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: idx == pathSegments.length - 1
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Theme.of(context).colorScheme.onSurface,
                                              ),
                                              onPressed: () {
                                                iClient.navigateUp(times: pathSegments.length - 1 - idx);
                                              },
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                                ),
                                                child: Text(
                                                  segment,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            
                            // Paths section with different views
                            _buildPathsSection(paths, iClient),
                            
                            // Objects section with different views
                            _buildObjectsSection(objects, iClient),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: snapshot.connectionState == ConnectionState.waiting
                                ? const LinearProgressIndicator()
                                : null,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: snapshot.connectionState == ConnectionState.waiting
                                ? Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.black38,
                                  )
                                : null,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            );
          });
    });
  }
  
  Widget _buildPathsSection(List<Record> paths, InventoryClient iClient) {
    switch (iClient.viewMode) {
      case ViewMode.list:
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: paths.length,
          itemBuilder: (context, index) {
            final record = paths[index];
            return PathItemListTile(
              record: record, 
              isSelected: iClient.isRecordSelected(record),
              onSelect: () {
                iClient.toggleRecordSelected(record);
              },
              onNavigate: () async {
                try {
                  await iClient.navigateTo(record);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to open directory: $e")),
                    );
                  }
                }
              },
              isAnySelected: iClient.isAnyRecordSelected,
            );
          },
        );
        
      case ViewMode.tiles:
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: paths.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            childAspectRatio: 4.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final record = paths[index];
            return PathInventoryTile(
              record: record,
              selected: iClient.isRecordSelected(record),
              onLongPress: () async {
                iClient.toggleRecordSelected(record);
              },
              onTap: iClient.isAnyRecordSelected
                  ? () {
                      iClient.toggleRecordSelected(record);
                    }
                  : () async {
                      try {
                        await iClient.navigateTo(record);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to open directory: $e")),
                          );
                        }
                      }
                    },
            );
          },
        );
        
      case ViewMode.icons:
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: paths.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final record = paths[index];
            final isDirectory = record.recordType == RecordType.directory;
            final iconColor = isDirectory ? Colors.amber : Colors.lightBlue;
            final icon = isDirectory ? Icons.folder : Icons.link;
            
            return Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: iClient.isRecordSelected(record) 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: InkWell(
                onTap: iClient.isAnyRecordSelected
                    ? () {
                        iClient.toggleRecordSelected(record);
                      }
                    : () async {
                        try {
                          await iClient.navigateTo(record);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to open directory: $e")),
                            );
                          }
                        }
                      },
                onLongPress: () {
                  iClient.toggleRecordSelected(record);
                },
                splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          icon,
                          size: 28,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.formattedName.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    }
  }
  
  Widget _buildObjectsSection(List<Record> objects, InventoryClient iClient) {
    switch (iClient.viewMode) {
      case ViewMode.list:
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: objects.length,
          itemBuilder: (context, index) {
            final record = objects[index];
            return ObjectItemListTile(
              record: record,
              isSelected: iClient.isRecordSelected(record),
              isAnySelected: iClient.isAnyRecordSelected,
              onSelect: () {
                iClient.toggleRecordSelected(record);
              },
              onOpen: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute( 
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(record.formattedName.toString()),
                      ),
                      body: Center (
                        child: CachedNetworkImage(
                          imageUrl: (Aux.resdbToHttp(record.thumbnailUri)),
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        
      case ViewMode.tiles:
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: objects.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final record = objects[index];
            return ObjectInventoryTile(
              record: record,
              selected: iClient.isRecordSelected(record),
              onTap: iClient.isAnyRecordSelected
                  ? () async {
                      iClient.toggleRecordSelected(record);
                    }
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute( 
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(record.formattedName.toString()),
                            ),
                            body: Center (
                              child: CachedNetworkImage(
                                imageUrl: (Aux.resdbToHttp(record.thumbnailUri)),
                                placeholder: (context, url) => CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.broken_image_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
              onLongPress: () async {
                iClient.toggleRecordSelected(record);
              },
            );
          },
        );
        
      case ViewMode.icons:
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: objects.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            childAspectRatio: 0.78, 
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final record = objects[index];
            final colorScheme = Theme.of(context).colorScheme;
            
            return Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: iClient.isRecordSelected(record) 
                  ? colorScheme.primaryContainer 
                  : colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: InkWell(
                onTap: iClient.isAnyRecordSelected
                    ? () {
                        iClient.toggleRecordSelected(record);
                      }
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute( 
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(record.formattedName.toString()),
                              ),
                              body: Center (
                                child: CachedNetworkImage(
                                  imageUrl: (Aux.resdbToHttp(record.thumbnailUri)),
                                  placeholder: (context, url) => CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.broken_image_rounded,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                onLongPress: () {
                  iClient.toggleRecordSelected(record);
                },
                splashColor: colorScheme.primary.withOpacity(0.1),
                highlightColor: colorScheme.primary.withOpacity(0.05),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed height container for image
                    SizedBox(
                      height: 62,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: Aux.resdbToHttp(record.thumbnailUri),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            )
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.secondaryContainer.withOpacity(0.5),
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: colorScheme.onSecondaryContainer,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Simplified text area with minimal padding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 2, 4, 3),
                      child: Text(
                        record.formattedName.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 11,
                          height: 1.0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
