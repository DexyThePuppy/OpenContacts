// import 'package:open_contacts/models/users/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_contacts/apis/session_api.dart';
import 'package:open_contacts/auxiliary.dart';
import 'package:open_contacts/client_holder.dart';
import 'package:open_contacts/models/session.dart';
import 'package:open_contacts/widgets/formatted_text.dart';
import 'package:open_contacts/widgets/panorama.dart';
import 'package:open_contacts/widgets/settings_page.dart';
import 'package:flutter/material.dart';

class SessionView extends StatefulWidget {
  const SessionView({required this.session, super.key});

  final Session session;

  @override
  State<SessionView> createState() => _SessionViewState();
}
class _SessionViewState extends State<SessionView> {
  Future<Session>? _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = Future.value(widget.session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sessionFuture,
      builder: (context, snapshot) {
        final session = snapshot.data ?? widget.session;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_outlined,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: FormattedText(
              session.formattedName,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            scrolledUnderElevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _sessionFuture = SessionApi.getSession(ClientHolder.of(context).apiClient, sessionId: session.id);
              });
              await _sessionFuture;
            },
            child: ListView(
              children: <Widget>[
                    SizedBox(
                      height: 192,
                      child: CachedNetworkImage(
                        imageUrl: Aux.resdbToHttp(session.thumbnailUrl),
                        imageBuilder: (context, image) {
                          return Material(
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text("Session Preview"),
                                      ),
                                      body: Center(
                                        child: Panorama(
                                          sensitivity: 2,
                                          minZoom: 0.5,
                                          zoom: 0.5,
                                          child: Image(image: image),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  SizedBox.expand(
                                    child: Image(
                                      image: image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Icon(Icons.panorama_photosphere),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: 64,
                        ),
                        placeholder: (context, uri) => const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8),
                            child: session.formattedDescription.isEmpty
                                ? Text("No description", style: Theme.of(context).textTheme.labelLarge)
                                : FormattedText(
                                    session.formattedDescription,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                          ),
                          const ListSectionHeader(
                            leadingText: "Tags:",
                            showLine: false,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            child: Text(
                              session.tags.isEmpty ? "None" : session.tags.join(", "),
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.start,
                              softWrap: true,
                            ),
                          ),
                          const ListSectionHeader(
                            leadingText: "Details:",
                            showLine: false,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Access: ",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  session.accessLevel.toReadableString(),
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          ListSectionHeader(
                            leadingText: "Users",
                            trailingText:
                                "${session.sessionUsers.length.toString().padLeft(2, "0")}/${session.maxUsers.toString().padLeft(2, "0")}",
                            showLine: false,
                          ),
                        ],
                      ),
                    ),
                  ] +
                  session.sessionUsers
                      .map((user) => ListTile(
                            dense: true,
                            leading: user.username == session.hostUsername && session.headlessHost
                            ? const Icon(Icons.dns, color: Color(0xFF294D5C))
                            : user.username == session.hostUsername && !session.headlessHost
                              ? const Icon(Icons.star, color: Color(0xFFE69E50))
                              : const Icon(Icons.person),
                            title: Text(
                              user.username,
                              textAlign: TextAlign.start,
                            ),
                            subtitle: Text(
                              user.isPresent ? "Active" : "Inactive",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: user.isPresent ?  Color.fromARGB(255, 89, 235, 91) : Color.fromARGB(255, 255, 118, 118),
                              )
                            ),
                          ))
                      .toList(),
            ),
          ),
        );
      },
    );
  }
}
