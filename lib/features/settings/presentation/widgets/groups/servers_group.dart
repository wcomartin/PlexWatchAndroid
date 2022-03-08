import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:reorderables/reorderables.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../../../../core/widgets/custom_list_tile.dart';
import '../../../../../core/widgets/heading.dart';
import '../../../../../translations/locale_keys.g.dart';
import '../../bloc/settings_bloc.dart';
import '../../pages/server_settings_page.dart';

class ServersGroup extends StatelessWidget {
  const ServersGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Heading(
                text: LocaleKeys.servers_title.tr(),
              ),
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ReorderableColumn(
                mainAxisSize: MainAxisSize.min,
                onReorder: (oldIndex, newIndex) {
                  if (state is SettingsSuccess) {
                    final int movedServerId = state.serverList[oldIndex].id!;

                    context.read<SettingsBloc>().add(
                          SettingsUpdateServerSort(
                            serverId: movedServerId,
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          ),
                        );
                  }
                },
                children: state is SettingsSuccess
                    ? state.serverList
                        .map(
                          (server) => CustomListTile(
                            key: ValueKey(server.tautulliId),
                            sensitive: true,
                            leading: WebsafeSvg.asset(
                              'assets/logos/logo_flat.svg',
                              color: Theme.of(context).colorScheme.tertiary,
                              height: 35,
                            ),
                            title: server.plexName,
                            subtitle: server.primaryActive!
                                ? server.primaryConnectionAddress
                                : server.secondaryConnectionAddress,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServerSettingsPage(serverId: server.id!),
                              ),
                            ),
                          ),
                        )
                        .toList()
                    : [],
              ),
            ),
          ],
        );
      },
    );
  }
}
