import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:system_theme/system_theme.dart';

import 'core/api/tautulli/models/register_device_model.dart';
import 'core/database/data/models/server_model.dart';
import 'core/error/failure.dart';
import 'core/global_keys/global_keys.dart';
import 'core/helpers/home_page_helper.dart';
import 'core/helpers/notification_helper.dart';
import 'core/helpers/theme_helper.dart';
import 'core/rate_app/rate_app.dart';
import 'core/types/theme_enhancement_type.dart';
import 'core/types/theme_type.dart';
import 'core/widgets/settings_not_loaded.dart';
import 'dependency_injection.dart' as di;
import 'features/activity/presentation/pages/activity_page.dart';
import 'features/announcements/presentation/bloc/announcements_bloc.dart';
import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/changelog/presentation/pages/changelog_page.dart';
import 'features/donate/presentation/pages/donate_page.dart';
import 'features/graphs/presentation/pages/graphs_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/libraries/presentation/pages/libraries_page.dart';
import 'features/logging/domain/usecases/logging.dart';
import 'features/onesignal/presentation/bloc/onesignal_health_bloc.dart';
import 'features/onesignal/presentation/bloc/onesignal_privacy_bloc.dart';
import 'features/onesignal/presentation/bloc/onesignal_sub_bloc.dart';
import 'features/onesignal/presentation/pages/onesignal_data_privacy.dart';
import 'features/recently_added/presentation/pages/recently_added_page.dart';
import 'features/settings/domain/usecases/settings.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/statistics/presentation/pages/statistics_page.dart';
import 'features/translation/presentation/pages/help_translate_page.dart';
import 'features/users/presentation/pages/users_page.dart';
import 'features/wizard/presentation/pages/wizard_page.dart';

class TautulliRemote extends StatefulWidget {
  final String? initialRoute;

  const TautulliRemote({
    super.key,
    this.initialRoute,
  });

  @override
  TautulliRemoteState createState() => TautulliRemoteState();
}

class TautulliRemoteState extends State<TautulliRemote> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoad());

    initalizeOneSignal();
    initalizeFLogConfiguration();
    checkforAppUpdate();
    rateApp.init();
    checkIfRegistrationUpdateNeeded();

    context.read<OneSignalPrivacyBloc>().add(OneSignalPrivacyCheck());
    // Delay OneSignalSubCheck on app start to avoid calling OSDeviceState
    // before OneSignal is fully initalized
    Future.delayed(const Duration(seconds: 2), () {
      context.read<OneSignalSubBloc>().add(OneSignalSubCheck());
    });
    context.read<AnnouncementsBloc>().add(AnnouncementsFetch());
  }

  Future<void> initalizeOneSignal() async {
    if (!mounted) return;

    // Enabling console logs for users to troubleshoot OneSignal issues
    await OneSignal.shared.setLogLevel(OSLogLevel.error, OSLogLevel.none);

    await OneSignal.shared.setLocationShared(false);

    await OneSignal.shared.setRequiresUserPrivacyConsent(true);

    await OneSignal.shared.setAppId("3b4b666a-d557-4b92-acdf-e2c8c4b95357");

    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      // Will be called whenever a notification is received
      event.complete(event.notification);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) async {
      // Will be called whenever a notification is opened/button pressed

      // Find the action type in the notification and open a page accordingly
      final data = await NotificationHelper.extractAdditionalData(
        result.notification.additionalData,
      );

      if (data != null) {
        final action = data['action'];

        // Add small delay to help make sure navigatorKey is not null
        await Future.delayed(const Duration(milliseconds: 10));

        switch (action) {
          case ('watched'):
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HistoryPage(
                  refreshOnLoad: true,
                ),
              ),
            );
            return;
          case ('created'):
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RecentlyAddedPage(
                  refreshOnLoad: true,
                ),
              ),
            );
            return;
          default:
            navigatorKey.currentState?.pushReplacementNamed('/activity');
        }
      }
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) async {
      // Will be called whenever the subscription changes

      // Only trigger new checks when userId or pushToken move from null to a value
      if (changes.to.userId != null || changes.to.pushToken != null) {
        context.read<OneSignalSubBloc>().add(OneSignalSubCheck());
        context.read<OneSignalHealthBloc>().add(OneSignalHealthCheck());

        if (changes.to.userId != null) {
          await oneSignalServerRegistrationChange();
        }
      }
    });

    // Check if registration update is needed after OneSignal is initalized to avoid sending a blank User ID
    await veryifyOneSignalConsent();
    checkIfRegistrationUpdateNeeded();
  }

  Future<void> veryifyOneSignalConsent() async {
    //! Wait for SettingsBloc to be SettingsSuccess
    await context.read<SettingsBloc>().stream.firstWhere((state) => state is SettingsSuccess);

    if (di.sl<Settings>().getOneSignalConsented() == true && await OneSignal.shared.userProvidedPrivacyConsent() == false) {
      await Future.delayed(const Duration(seconds: 1)).then((value) async {
        context.read<OneSignalPrivacyBloc>().add(
              OneSignalPrivacyReGrant(
                settingsBloc: context.read<SettingsBloc>(),
              ),
            );

        await Future.delayed(const Duration(seconds: 1)).then(
          (value) async => await oneSignalServerRegistrationChange(),
        );

        di.sl<Settings>().setRegistrationUpdateNeeded(false);
      });
    }

    return Future.value();
  }

  void initalizeFLogConfiguration() {
    FLog.applyConfigurations(
      LogsConfig()..activeLogLevel = LogLevel.ALL,
    );
  }

  Future<void> checkforAppUpdate() async {
    //! Wait for SettingsBloc to be SettingsSuccess
    await context.read<SettingsBloc>().stream.firstWhere((state) => state is SettingsSuccess);

    //TODO: Waiting on fix to app version update package, remove the force to flase code as well
    context.read<SettingsBloc>().add(const SettingsUpdateAppUpdateAvailable(appUpdateAvailable: false));

    // await AppVersionUpdate.checkForUpdates(
    //   appleId: '1570909086',
    //   playStoreId: 'com.tautulli.tautulli_remote',
    // ).then(
    //   (data) async {
    //     if (data.canUpdate != null) {
    //       context.read<SettingsBloc>().add(
    //             SettingsUpdateAppUpdateAvailable(
    //               appUpdateAvailable: data.canUpdate!,
    //             ),
    //           );
    //     }
    //   },
    // );
  }

  Future<void> checkIfRegistrationUpdateNeeded() async {
    //! Wait for SettingsBloc to be SettingsSuccess
    await context.read<SettingsBloc>().stream.firstWhere((state) => state is SettingsSuccess);

    if (di.sl<Settings>().getRegistrationUpdateNeeded()) {
      final servers = await di.sl<Settings>().getAllServers();

      if (servers.isNotEmpty) {
        di.sl<Logging>().info(
              'Settings :: App version changed, updating server registration',
            );

        for (ServerModel server in servers) {
          final failureOrRegisterDevice = await updateServerRegistration(server);

          failureOrRegisterDevice.fold(
            (failure) {
              di.sl<Logging>().error(
                    'Settings :: Failed to update registration for ${server.plexName} with new app version',
                  );
            },
            (results) async {
              await di.sl<Settings>().updateServer(server);

              di.sl<Logging>().info(
                    'Settings :: Updated registration for ${server.plexName} with new app version',
                  );

              di.sl<Settings>().setRegistrationUpdateNeeded(false);
            },
          );
        }
      }
    }
  }

  Future<void> oneSignalServerRegistrationChange() async {
    final servers = await di.sl<Settings>().getAllServers();

    di.sl<Logging>().info(
          'OneSignal :: OneSignal registration changed, updating server registration in 5 seconds',
        );

    await Future.delayed(const Duration(seconds: 5));

    for (ServerModel server in servers) {
      final failureOrRegisterDevice = await updateServerRegistration(server);

      failureOrRegisterDevice.fold(
        (failure) {
          di.sl<Logging>().error(
                'OneSignal :: Failed to update registration for ${server.plexName} with OneSignal ID',
              );
        },
        (results) async {
          await di.sl<Settings>().updateServer(
                server.copyWith(oneSignalRegistered: true),
              );

          di.sl<Logging>().info(
                'OneSignal :: Updated registration for ${server.plexName} with OneSignal ID',
              );

          di.sl<Settings>().setRegistrationUpdateNeeded(false);
        },
      );
    }
  }

  Future<dartz.Either<Failure, dartz.Tuple2<RegisterDeviceModel, bool>>> updateServerRegistration(
    ServerModel server,
  ) async {
    String connectionProtocol = server.primaryActive! ? server.primaryConnectionProtocol : server.secondaryConnectionProtocol!;
    String connectionDomain = server.primaryActive! ? server.primaryConnectionDomain : server.secondaryConnectionDomain!;
    String? connectionPath = server.primaryActive! ? server.primaryConnectionPath : server.secondaryConnectionPath;

    final failureOrRegisterDevice = await di.sl<Settings>().registerDevice(
          connectionProtocol: connectionProtocol,
          connectionDomain: connectionDomain,
          connectionPath: connectionPath ?? '',
          deviceToken: server.deviceToken,
          customHeaders: server.customHeaders,
        );

    return failureOrRegisterDevice;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        if (previous is SettingsSuccess && current is SettingsSuccess) {
          final bool fontChange = previous.appSettings.useAtkinsonHyperlegible != current.appSettings.useAtkinsonHyperlegible;
          final bool currentThemeIsDynamic = current.appSettings.theme == ThemeType.dynamic;
          final bool themeChange = previous.appSettings.theme != current.appSettings.theme;
          final bool themeSystemColorChange = previous.appSettings.themeUseSystemColor != current.appSettings.themeUseSystemColor;
          final bool themeCustomColorChange = previous.appSettings.themeCustomColor != current.appSettings.themeCustomColor;
          final bool themeEnhancementChange = previous.appSettings.themeEnhancement != current.appSettings.themeEnhancement;

          if (fontChange || themeChange || themeEnhancementChange || (currentThemeIsDynamic && (themeSystemColorChange || themeCustomColorChange))) {
            return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        final bool useAtkinsonHyperLegible = di.sl<Settings>().getUseAtkinsonHyperlegible();
        final ThemeType theme = di.sl<Settings>().getTheme();
        final bool themeUseSystemColor = di.sl<Settings>().getThemeUseSystemColor();
        final Color themeCustomColor = di.sl<Settings>().getThemeCustomColor();
        final Color systemColor = SystemTheme.accentColor.accent;
        final ThemeEnhancementType themeEnhancement = di.sl<Settings>().getThemeEnhancement();

        return MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Tautulli Remote',
          theme: ThemeHelper.themeSelector(
            theme: theme,
            color: (themeUseSystemColor && defaultTargetPlatform.supportsAccentColor) ? systemColor : themeCustomColor,
            enhancement: themeEnhancement,
            fontName: useAtkinsonHyperLegible ? 'Atkinson Hyperlegible' : null,
          ),
          builder: (context, child) {
            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsSuccess) {
                  return child!;
                }

                return const Scaffold(
                  body: SettingsNotLoaded(),
                );
              },
            );
          },
          routes: {
            ActivityPage.routeName: (_) => const ActivityPage(),
            AnnouncementsPage.routeName: (_) => const AnnouncementsPage(),
            ChangelogPage.routeName: (_) => const ChangelogPage(),
            DonatePage.routeName: (_) => const DonatePage(),
            GraphsPage.routeName: (_) => const GraphsPage(),
            HistoryPage.routeName: (_) => const HistoryPage(),
            HelpTranslatePage.routeName: (_) => const HelpTranslatePage(),
            LibrariesPage.routeName: (_) => const LibrariesPage(),
            OneSignalDataPrivacyPage.routeName: (_) => const OneSignalDataPrivacyPage(),
            RecentlyAddedPage.routeName: (_) => const RecentlyAddedPage(),
            SettingsPage.routeName: (_) => const SettingsPage(),
            StatisticsPage.routeName: (_) => const StatisticsPage(),
            UsersPage.routeName: (_) => const UsersPage(),
            WizardPage.routeName: (_) => const WizardPage(),
          },
          initialRoute: widget.initialRoute,
          home: HomePageHelper.get(),
        );
      },
    );
  }
}
