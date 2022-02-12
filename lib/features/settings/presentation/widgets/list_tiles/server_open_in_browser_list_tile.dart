import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/database/data/models/server_model.dart';

class ServerOpenInBrowserListTile extends StatelessWidget {
  final ServerModel server;

  const ServerOpenInBrowserListTile({
    Key? key,
    required this.server,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 35,
              child: FaIcon(FontAwesomeIcons.windowMaximize),
            ),
          ],
        ),
        title: Text('Open ${server.plexName} in browser'),
        onTap: () async {
          if (server.primaryActive != false) {
            await launch(server.primaryConnectionAddress);
          } else if (server.secondaryConnectionAddress != null) {
            await launch(server.secondaryConnectionAddress!);
          }
        },
        onLongPress: () async {
          // If a secondary connection address is configured launch
          // the non active address on a long press
          if (server.secondaryConnectionAddress != null) {
            if (server.primaryActive != false) {
              await launch(server.secondaryConnectionAddress!);
            } else {
              await launch(server.primaryConnectionAddress);
            }
          }
        },
      ),
    );
  }
}
