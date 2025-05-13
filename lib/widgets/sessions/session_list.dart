import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/clients/session_client.dart';
import 'package:open_contacts/models/session.dart';
import 'package:open_contacts/widgets/default_error_widget.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/widgets/sessions/session_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:open_contacts/models/view_modes.dart';

class SessionList extends StatefulWidget {
  const SessionList({super.key});

  @override
  State<SessionList> createState() => _SessionListState();
}
class OnKeyIntent extends Intent{
  const OnKeyIntent();
}

const onKey = SingleActivator(LogicalKeyboardKey.f5);

class _SessionListState extends State<SessionList> with AutomaticKeepAliveClientMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sClient = Provider.of<SessionClient>(context, listen: false);
    if (sClient.sessionsFuture == null) {
      sClient.initSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: Provider.of<SessionClient>(context),
      child: Consumer<SessionClient>(
        builder: (BuildContext context, SessionClient sClient, Widget? child) {
          return FutureBuilder<List<Session>>(
            future: sClient.sessionsFuture,
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      sClient.reloadSessions();
                      try {
                        await sClient.sessionsFuture;
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                    child: data.isEmpty && snapshot.connectionState == ConnectionState.done
                        ? const DefaultErrorWidget(
                            title: "No Sessions Found",
                            message: "Try to adjust your filters",
                            iconOverride: Icons.question_mark,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: switch (sClient.viewMode) {
                                ViewMode.list => _buildListView(data, sClient),
                                ViewMode.tiles => _buildTilesView(data, sClient),
                                ViewMode.icons => _buildIconsView(data, sClient),
                              },
                            ),
                          ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting) const LinearProgressIndicator()
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Session> sessions, SessionClient sClient) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionListTile(session: session);
      },
    );
  }

  Widget _buildTilesView(List<Session> sessions, SessionClient sClient) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sessions.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SessionView(session: session)));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: session.id,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: Aux.resdbToHttp(session.thumbnailUrl),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          placeholder: (context, uri) => Container(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          "${session.sessionUsers.length}/${session.maxUsers}",
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    if (session.headlessHost)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.dns,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormattedText(
                        session.formattedName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.1,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Host: ${session.hostUsername}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconsView(List<Session> sessions, SessionClient sClient) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      itemCount: sessions.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SessionView(session: session))
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: session.id,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              imageUrl: Aux.resdbToHttp(session.thumbnailUrl),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                radius: 25,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 1, bottom: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          "${session.sessionUsers.length}",
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    session.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      height: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    session.hostUsername,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      height: 1.0,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
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

  @override
  bool get wantKeepAlive => true;
}

class SessionListTile extends StatefulWidget {
  final Session session;

  const SessionListTile({
    required this.session,
    super.key,
  });

  @override
  State<SessionListTile> createState() => _SessionListTileState();
}

class _SessionListTileState extends State<SessionListTile> {
  bool isHovered = false;
  Offset? mousePosition;

  @override
  Widget build(BuildContext context) {
    final imageUri = Aux.resdbToHttp(widget.session.thumbnailUrl);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SessionView(session: widget.session))
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Material(
                    color: isHovered ? colorScheme.surfaceContainerHighest.withOpacity(0.5) : Colors.transparent,
                    elevation: isHovered ? 1 : 0,
                    shadowColor: colorScheme.shadow.withOpacity(0.5),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isHovered ? BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 0.5) : BorderSide.none,
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
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FormattedText(
                              widget.session.formattedName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.session.headlessHost)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              child: Icon(
                                Icons.dns,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${widget.session.sessionUsers.length}/${widget.session.maxUsers}",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "Host: ${widget.session.hostUsername}",
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
