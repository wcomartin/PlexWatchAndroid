import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/donate/presentation/pages/donate_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/libraries/presentation/pages/libraries_page.dart';
import '../../features/recent/presentation/pages/recently_added_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/synced_items/presentation/pages/synced_items_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../helpers/color_palette_helper.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);

    return Drawer(
      child: Column(
        children: [
          // Add colored bar behind status bar
          Container(
            height: MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(color: TautulliColorPalette.midnight),
          ),
          // Logo section
          Container(
            height: 100,
            decoration: BoxDecoration(color: TautulliColorPalette.midnight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        padding: const EdgeInsets.only(right: 3),
                        child: Image.asset('assets/logo/logo_transparent.png'),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Tautulli',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Remote',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                              ),
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
          Expanded(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0),
              children: <Widget>[
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.tv,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Activity'),
                  onTap: () {
                    if (route.settings.name != ActivityPage.routeName &&
                        route.settings.name != '/') {
                      Navigator.of(context)
                          .pushReplacementNamed(ActivityPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ActivityPage.routeName);
                  },
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.history,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('History'),
                  onTap: () {
                    if (route.settings.name != HistoryPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(HistoryPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(HistoryPage.routeName);
                  },
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.clock,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Recently Added'),
                  onTap: () {
                    if (route.settings.name != RecentlyAddedPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(RecentlyAddedPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RecentlyAddedPage.routeName);
                  },
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.photoVideo,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Libraries'),
                  onTap: () {
                    if (route.settings.name != LibrariesPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(LibrariesPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(LibrariesPage.routeName);
                  },
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.users,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Users'),
                  onTap: () {
                    if (route.settings.name != UsersPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(UsersPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(UsersPage.routeName);
                  },
                ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.listOl,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Statistics'),
                  onTap: () {
                    if (route.settings.name != StatisticsPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(StatisticsPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(StatisticsPage.routeName);
                  },
                ),
                // ListTile(
                //   leading: FaIcon(
                //     FontAwesomeIcons.chartBar,
                //     size: 20,
                //     color: TautulliColorPalette.not_white,
                //   ),
                //   title: Text('Graphs'),
                //   onTap: () {
                //     // if (route.settings.name != StatisticsPage.routeName) {
                //     //   Navigator.of(context)
                //     //       .pushReplacementNamed(StatisticsPage.routeName);
                //     // } else {
                //     //   Navigator.pop(context);
                //     // }
                //   },
                //   onLongPress: () {
                //     // Navigator.of(context)
                //     //     .pushReplacementNamed(StatisticsPage.routeName);
                //   },
                // ),
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.cloudDownloadAlt,
                    size: 20,
                    color: TautulliColorPalette.not_white,
                  ),
                  title: Text('Synced Items'),
                  onTap: () {
                    if (route.settings.name != SyncedItemsPage.routeName) {
                      Navigator.of(context)
                          .pushReplacementNamed(SyncedItemsPage.routeName);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context)
                        .pushReplacementNamed(SyncedItemsPage.routeName);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: PlexColorPalette.raven,
            ),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.solidHeart,
              size: 20,
              color: Colors.red[400],
            ),
            title: Text('Donate'),
            onTap: () {
              if (route.settings.name != DonatePage.routeName) {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(DonatePage.routeName);
              } else {
                Navigator.pop(context);
              }
            },
            onLongPress: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(DonatePage.routeName);
            },
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.cogs,
              size: 20,
              color: TautulliColorPalette.not_white,
            ),
            title: Text('Settings'),
            onTap: () {
              if (route.settings.name != SettingsPage.routeName) {
                Navigator.of(context)
                    .pushReplacementNamed(SettingsPage.routeName);
              } else {
                Navigator.pop(context);
              }
            },
            onLongPress: () {
              Navigator.of(context)
                  .pushReplacementNamed(SettingsPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}
