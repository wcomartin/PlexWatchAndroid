import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:system_theme/system_theme.dart';

import '../../../../core/device_info/device_info.dart';
import '../../../../core/package_information/package_information.dart';
import '../../../../core/widgets/card_with_forced_tint.dart';
import '../../../../core/widgets/heading.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../dependency_injection.dart' as di;
import '../../../../translations/locale_keys.g.dart';
import '../../../announcements/presentation/bloc/announcements_bloc.dart';
import '../../../onesignal/presentation/bloc/onesignal_health_bloc.dart';
import '../../../onesignal/presentation/bloc/onesignal_status_bloc.dart';
import '../bloc/settings_bloc.dart';

class DataDumpPage extends StatelessWidget {
  const DataDumpPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<OneSignalHealthBloc>().add(OneSignalHealthCheck());
    context.read<SettingsBloc>().add(
          const SettingsLoad(updateServerInfo: false),
        );

    return BlocProvider(
      create: (context) => di.sl<OneSignalStatusBloc>()
        ..add(
          OneSignalStatusLoad(),
        ),
      child: const DataDumpView(),
    );
  }
}

class DataDumpView extends StatelessWidget {
  const DataDumpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(LocaleKeys.data_dump_title).tr(),
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            CardWithForcedTint(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.data_dump_warning_line_1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ).tr(),
                          Text(
                            LocaleKeys.data_dump_warning_line_2,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ).tr(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            const _DeviceDetails(),
            const Gap(8),
            const _AppDetails(),
            const Gap(8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return _AppSettings(settingsState: state as SettingsSuccess);
              },
            ),
            const Gap(8),
            const _OneSignalStatus(),
            const Gap(8),
            const _AnnouncementsDumpGroup(),
            const Gap(8),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return _ServerDumpGroup(
                  settingsState: state as SettingsSuccess,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDumpGroup extends StatelessWidget {
  final String title;
  final List<Widget> widgetList;

  const _SettingDumpGroup({
    required this.title,
    required this.widgetList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Heading(text: title),
        ),
        const Gap(8),
        CardWithForcedTint(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgetList,
            ),
          ),
        ),
      ],
    );
  }
}

class _DataDumpRowHeading extends StatelessWidget {
  final String text;

  const _DataDumpRowHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DataDumpRow extends StatelessWidget {
  final List<Widget> children;

  const _DataDumpRow({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
        const Divider(),
      ],
    );
  }
}

class _DeviceDetails extends StatelessWidget {
  const _DeviceDetails();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return _SettingDumpGroup(
      title: 'Device Details',
      widgetList: [
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Aspect Ratio'),
            const Gap(16),
            Text(mediaQuery.size.aspectRatio.toString()),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Longest Side'),
            const Gap(16),
            Text(mediaQuery.size.longestSide.toString()),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Name'),
            const Gap(16),
            FutureBuilder(
              future: di.sl<DeviceInfo>().model,
              builder: (context, snapshot) {
                return Text(snapshot.data.toString());
              },
            ),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Orientation'),
            const Gap(16),
            Text(mediaQuery.orientation.toString()),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Platform'),
            const Gap(16),
            Text(di.sl<DeviceInfo>().platform),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Shortest Side'),
            const Gap(16),
            Text(mediaQuery.size.shortestSide.toString()),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Text Scale Factor'),
            const Gap(16),
            Text(mediaQuery.textScaler.scale(1).toString()),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Unique ID'),
            const Gap(16),
            Expanded(
              child: FutureBuilder(
                future: di.sl<DeviceInfo>().uniqueId,
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data.toString(),
                    textAlign: TextAlign.end,
                  );
                },
              ),
            ),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Version'),
            const Gap(16),
            FutureBuilder(
              future: di.sl<DeviceInfo>().version,
              builder: (context, snapshot) {
                return Text(snapshot.data.toString());
              },
            ),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('System Accent'),
            const Gap(16),
            Text(
              defaultTargetPlatform.supportsAccentColor ? SystemTheme.accentColor.accent.toString() : 'Unsupported',
              style: TextStyle(
                color: defaultTargetPlatform.supportsAccentColor ? SystemTheme.accentColor.accent : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppDetails extends StatelessWidget {
  const _AppDetails();

  @override
  Widget build(BuildContext context) {
    return _SettingDumpGroup(
      title: 'App Details',
      widgetList: [
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Version'),
            const Gap(16),
            FutureBuilder(
              future: PackageInformationImpl().version,
              builder: (context, snapshot) {
                return Text(snapshot.data.toString());
              },
            ),
          ],
        ),
        _DataDumpRow(
          children: [
            const _DataDumpRowHeading('Build Number'),
            const Gap(16),
            FutureBuilder(
              future: PackageInformationImpl().buildNumber,
              builder: (context, snapshot) {
                return Text(snapshot.data.toString());
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _AppSettings extends StatelessWidget {
  final SettingsSuccess settingsState;

  const _AppSettings({
    required this.settingsState,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingDumpGroup(
      title: 'App Settings',
      widgetList: settingsState.appSettings
          .dump()
          .entries
          .map(
            (e) => _DataDumpRow(
              children: [
                GestureDetector(
                  onLongPress: e.key == 'Patch'
                      ? () async {
                          final shorebirdCodePush = ShorebirdCodePush();
                          final isUpdateAvailable = await shorebirdCodePush.isNewPatchAvailableForDownload();

                          if (di.sl<DeviceInfo>().platform == 'ios' && await di.sl<DeviceInfo>().version < 10) {
                            HapticFeedback.vibrate();
                          } else {
                            HapticFeedback.heavyImpact();
                          }

                          if (isUpdateAvailable) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: 'Patch available, please wait...',
                            );

                            await shorebirdCodePush.downloadUpdateIfAvailable();

                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: 'Patch downloaded, restart app to apply',
                            );
                          } else {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_SHORT,
                              msg: 'No patch available',
                            );
                          }
                        }
                      : null,
                  child: _DataDumpRowHeading(e.key),
                ),
                const Gap(16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      e.value,
                      style: e.key == 'Theme Custom Color'
                          ? TextStyle(
                              color: settingsState.appSettings.themeCustomColor,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _OneSignalStatus extends StatelessWidget {
  const _OneSignalStatus();

  @override
  Widget build(BuildContext context) {
    return _SettingDumpGroup(
      title: 'OneSignal Status',
      widgetList: [
        BlocBuilder<OneSignalHealthBloc, OneSignalHealthState>(
          builder: (context, state) {
            return _DataDumpRow(
              children: [
                const _DataDumpRowHeading('Can Connect to OneSignal'),
                const Gap(16),
                if (state is OneSignalHealthSuccess) const Text('true'),
                if (state is OneSignalHealthFailure) const Text('false'),
                if (state is OneSignalHealthInProgress) const Text('checking'),
              ],
            );
          },
        ),
        BlocBuilder<OneSignalStatusBloc, OneSignalStatusState>(
          builder: (context, state) {
            if (state is OneSignalStatusFailure) {
              return const Center(
                child: Text('Error Loading OneSignal Status'),
              );
            }
            if (state is OneSignalStatusSuccess) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DataDumpRow(
                    children: [
                      const _DataDumpRowHeading('Notification Permission'),
                      const Gap(16),
                      Expanded(
                        child: Text(
                          state.hasNotificationPermission.toString(),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  _DataDumpRow(
                    children: [
                      const _DataDumpRowHeading('Push Disabled'),
                      const Gap(16),
                      Text(
                        state.isPushDisabled.toString(),
                      ),
                    ],
                  ),
                  _DataDumpRow(
                    children: [
                      const _DataDumpRowHeading('Subscribed'),
                      const Gap(16),
                      Text(
                        state.isSubscribed.toString(),
                      ),
                    ],
                  ),
                  _DataDumpRow(
                    children: [
                      const _DataDumpRowHeading('User ID'),
                      const Gap(16),
                      Expanded(
                        child: Text(
                          state.userId,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return const Center(
              child: Text('Loading OneSignal Status'),
            );
          },
        )
      ],
    );
  }
}

class _AnnouncementsDumpGroup extends StatelessWidget {
  const _AnnouncementsDumpGroup();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
      builder: (context, state) {
        if (state is AnnouncementsSuccess) {
          return _SettingDumpGroup(
            title: 'Announcements',
            widgetList: [
              _DataDumpRow(
                children: [
                  const _DataDumpRowHeading('Unread'),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      state.unread.toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              _DataDumpRow(
                children: [
                  const _DataDumpRowHeading('Total'),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      state.announcementList.length.toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              _DataDumpRow(
                children: [
                  const _DataDumpRowHeading('Filtered'),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      (state.announcementList.length - state.filteredList.length).toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              _DataDumpRow(
                children: [
                  const _DataDumpRowHeading('Max ID'),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      state.maxId.toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              _DataDumpRow(
                children: [
                  const _DataDumpRowHeading('Last Read ID'),
                  const Gap(16),
                  Expanded(
                    child: Text(
                      state.lastReadAnnouncementId.toString(),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        if (state is AnnouncementsFailure) {}

        return Container();
      },
    );
  }
}

class _ServerDumpGroup extends StatelessWidget {
  final SettingsSuccess settingsState;

  const _ServerDumpGroup({
    required this.settingsState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: settingsState.serverList
          .map(
            (server) => _SettingDumpGroup(
              title: server.plexName,
              widgetList: [
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('ID'),
                    const Gap(16),
                    Text(server.id.toString()),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Sort Index'),
                    const Gap(16),
                    Text(server.sortIndex.toString()),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Plex Identifier'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.plexIdentifier,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Tautulli ID'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.tautulliId,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Primary Address'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.primaryConnectionAddress,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Primary Protocol'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.primaryConnectionProtocol,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Primary Domain'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.primaryConnectionDomain,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Primary Path'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.primaryConnectionPath ?? '',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Secondary Address'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.secondaryConnectionAddress ?? '',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [const _DataDumpRowHeading('Secondary Protocol'), const Gap(16), Text(server.secondaryConnectionProtocol ?? '')],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Secondary Domain'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.secondaryConnectionDomain ?? '',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Secondary Path'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.secondaryConnectionPath ?? '',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Device Token'),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        server.deviceToken,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Primary Active'),
                    const Gap(16),
                    Text(server.primaryActive.toString()),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('OneSignal Registered'),
                    const Gap(16),
                    Text(server.oneSignalRegistered.toString()),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Plex Pass'),
                    const Gap(16),
                    Text(server.plexPass.toString()),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Date Format'),
                    const Gap(16),
                    Text(server.dateFormat ?? ''),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Time Format'),
                    const Gap(16),
                    Text(server.timeFormat ?? ''),
                  ],
                ),
                _DataDumpRow(
                  children: [
                    const _DataDumpRowHeading('Custom Headers'),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: server.customHeaders
                            .map(
                              (header) => Text(
                                '{${header.key} : ${header.value}}',
                                textAlign: TextAlign.end,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
