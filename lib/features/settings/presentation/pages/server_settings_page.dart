import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

import '../../../../core/widgets/list_tile_group.dart';
import '../../../../core/widgets/page_body.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/custom_header_list_tile.dart';
import '../widgets/custom_header_type_dialog.dart';
import '../widgets/server_device_token_list_tile.dart';
import '../widgets/server_open_in_browser_list_tile.dart';
import '../widgets/server_primary_connection_list_tile.dart';
import '../widgets/server_secondary_connection_list_tile.dart';

class ServerSettingsPage extends StatelessWidget {
  final int serverId;

  const ServerSettingsPage({
    Key? key,
    required this.serverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServerSettingsView(
      serverId: serverId,
    );
  }
}

class ServerSettingsView extends StatelessWidget {
  final int serverId;

  const ServerSettingsView({
    Key? key,
    required this.serverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        state as SettingsSuccess;

        final server = state.serverList.firstWhere(
          (server) => server.id == serverId,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(server.plexName),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.trash),
                onPressed: () {},
              ),
            ],
          ),
          body: PageBody(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTileGroup(
                  heading: 'Connection Details',
                  listTiles: [
                    ServerPrimaryConnectionListTile(server: server),
                    ServerSecondaryConnectionListTile(server: server),
                    ServerDeviceTokenListTile(deviceToken: server.deviceToken),
                  ],
                ),
                const Gap(8),
                ListTileGroup(
                  heading: 'Custom HTTP Headers',
                  listTiles: server.customHeaders
                      .map(
                        (header) => CustomHeaderListTile(
                          title: header.key,
                          subtitle: header.value,
                        ),
                      )
                      .toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Add Custom HTTP Header'),
                        onPressed: () async => await showDialog(
                          context: context,
                          builder: (context) => const CustomHeaderTypeDialog(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                ListTileGroup(
                  heading: 'Other',
                  listTiles: [
                    ServerOpenInBrowserListTile(server: server),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
