import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tautulli_remote/core/database/data/models/server_model.dart';
import 'package:tautulli_remote/features/settings/data/models/plex_server_info_model.dart';
import 'package:tautulli_remote/features/settings/data/models/tautulli_settings_general_model.dart';
import 'package:tautulli_remote/features/settings/domain/entities/plex_server_info.dart';
import 'package:tautulli_remote/features/settings/domain/repositories/settings_repository.dart';
import 'package:tautulli_remote/features/settings/domain/usecases/settings.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  Settings settings;
  MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    settings = Settings(
      repository: mockSettingsRepository,
    );
  });

  final int tId = 1;
  final String tPrimaryConnectionAddress = 'http://tautuli.domain.com';
  final String tPrimaryConnectionProtocol = 'http';
  final String tPrimaryConnectionDomain = 'tautuli.domain.com';
  final String tPrimaryConnectionPath = '/tautulli';
  final String tSecondaryConnectionAddress = 'http://tautuli.domain.com';
  final String tDeviceToken = 'abc';
  final String tTautulliId = 'jkl';
  final String tPlexName = 'Plex';
  final String tDateFormat = 'YYYY-MM-DD';
  final String tTimeFormat = 'HH:mm';

  final String tStatsType = 'duration';

  final ServerModel tServerModel = ServerModel(
    id: tId,
    primaryConnectionAddress: tPrimaryConnectionAddress,
    primaryConnectionProtocol: tPrimaryConnectionProtocol,
    primaryConnectionDomain: tPrimaryConnectionDomain,
    primaryConnectionPath: tPrimaryConnectionPath,
    deviceToken: tDeviceToken,
    tautulliId: tTautulliId,
    plexName: tPlexName,
    primaryActive: true,
    plexPass: true,
    dateFormat: tDateFormat,
    timeFormat: tTimeFormat,
  );

  final List<ServerModel> tServerList = [tServerModel];

  final plexServerInfoJson = json.decode(fixture('plex_server_info.json'));
  final PlexServerInfo tPlexServerInfo =
      PlexServerInfoModel.fromJson(plexServerInfoJson['response']['data']);

  final tautulliSettingsJson = json.decode(fixture('tautulli_settings.json'));
  final tautulliSettingsGeneral = TautulliSettingsGeneralModel.fromJson(
      tautulliSettingsJson['response']['data']['General']);
  final tTautulliSettingsMap = {
    'general': tautulliSettingsGeneral,
  };

  test(
    'addServer should forward the request to the repository',
    () async {
      // act
      settings.addServer(
        primaryConnectionAddress: tPrimaryConnectionAddress,
        deviceToken: tDeviceToken,
        tautulliId: tTautulliId,
        plexName: tPlexName,
        primaryActive: true,
        plexPass: true,
      );
      // assert
      verify(
        mockSettingsRepository.addServer(
          primaryConnectionAddress: tPrimaryConnectionAddress,
          deviceToken: tDeviceToken,
          tautulliId: tTautulliId,
          plexName: tPlexName,
          primaryActive: true,
          plexPass: true,
        ),
      );
    },
  );

  test(
    'deleteServer should forward the request to the repository',
    () async {
      // act
      settings.deleteServer(tId);
      // assert
      verify(mockSettingsRepository.deleteServer(tId));
    },
  );

  test(
    'updateServer should forward the request to the repository',
    () async {
      // act
      settings.updateServer(tServerModel);
      // assert
      verify(mockSettingsRepository.updateServer(tServerModel));
    },
  );

  test(
    'updateServerById should forward the request to the repository',
    () async {
      // act
      settings.updateServerById(
        id: tId,
        primaryConnectionAddress: tPrimaryConnectionAddress,
        secondaryConnectionAddress: tSecondaryConnectionAddress,
        deviceToken: tDeviceToken,
        tautulliId: tTautulliId,
        plexName: tPlexName,
        primaryActive: true,
        plexPass: true,
        dateFormat: tDateFormat,
        timeFormat: tTimeFormat,
      );
      // assert
      verify(
        mockSettingsRepository.updateServerById(
          id: tId,
          primaryConnectionAddress: tPrimaryConnectionAddress,
          secondaryConnectionAddress: tSecondaryConnectionAddress,
          deviceToken: tDeviceToken,
          tautulliId: tTautulliId,
          plexName: tPlexName,
          primaryActive: true,
          plexPass: true,
          dateFormat: tDateFormat,
          timeFormat: tTimeFormat,
        ),
      );
    },
  );

  test(
    'getAllServers should return a List of ServerModel',
    () async {
      // arrange
      when(mockSettingsRepository.getAllServers())
          .thenAnswer((_) async => tServerList);
      // act
      final List<ServerModel> servers = await settings.getAllServers();
      // assert
      expect(servers, equals(tServerList));
    },
  );

  test(
    'getServer should return a single ServerModel',
    () async {
      // arrange
      when(mockSettingsRepository.getServer(any))
          .thenAnswer((_) async => tServerModel);
      // act
      final server = await settings.getServer(tId);
      // assert
      expect(server, equals(tServerModel));
    },
  );

  test(
    'getServerByTautulliId should return a single ServerModel',
    () async {
      // arrange
      when(mockSettingsRepository.getServerByTautulliId(any))
          .thenAnswer((_) async => tServerModel);
      // act
      final server = await settings.getServerByTautulliId(tTautulliId);
      // assert
      expect(server, equals(tServerModel));
    },
  );

  test(
    'updatePrimaryConnection should forward the request to the repository',
    () async {
      // act
      settings.updatePrimaryConnection(
        id: tId,
        primaryConnectionAddress: tPrimaryConnectionAddress,
      );
      // assert
      verify(
        mockSettingsRepository.updatePrimaryConnection(
          id: tId,
          primaryConnectionAddress: tPrimaryConnectionAddress,
        ),
      );
    },
  );

  test(
    'updateSecondaryConnection should forward the request to the repository',
    () async {
      // act
      settings.updateSecondaryConnection(
        id: tId,
        secondaryConnectionAddress: tPrimaryConnectionAddress,
      );
      // assert
      verify(
        mockSettingsRepository.updateSecondaryConnection(
          id: tId,
          secondaryConnectionAddress: tPrimaryConnectionAddress,
        ),
      );
    },
  );

  test(
    'updateDeviceToken should forward the request to the repository',
    () async {
      // act
      settings.updateDeviceToken(
        id: tId,
        deviceToken: tDeviceToken,
      );
      // assert
      verify(
        mockSettingsRepository.updateDeviceToken(
          id: tId,
          deviceToken: tDeviceToken,
        ),
      );
    },
  );

  test(
    'should get PlexServerInfo from repository',
    () async {
      // arrange
      when(
        mockSettingsRepository.getPlexServerInfo(any),
      ).thenAnswer((_) async => Right(tPlexServerInfo));
      // act
      final result = await settings.getPlexServerInfo(tTautulliId);
      // assert
      expect(result, equals(Right(tPlexServerInfo)));
    },
  );

  test(
    'should get TautulliSettings from repository',
    () async {
      // arrange
      when(
        mockSettingsRepository.getTautulliSettings(any),
      ).thenAnswer((_) async => Right(tTautulliSettingsMap));
      // act
      final result = await settings.getTautulliSettings(tTautulliId);
      // assert
      expect(result, equals(Right(tTautulliSettingsMap)));
    },
  );

  test(
    'getServerTimeout should get server timeout from settings',
    () async {
      // arrange
      when(mockSettingsRepository.getServerTimeout())
          .thenAnswer((_) async => 3);
      // act
      final result = await settings.getServerTimeout();
      // assert
      expect(result, equals(3));
      verify(mockSettingsRepository.getServerTimeout());
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'setServerTimeout should forward request to the repository',
    () async {
      // act
      await settings.setServerTimeout(3);
      // assert
      verify(mockSettingsRepository.setServerTimeout(3));
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'getRefreshRate should get refresh rate from settings',
    () async {
      // arrange
      when(mockSettingsRepository.getRefreshRate()).thenAnswer((_) async => 3);
      // act
      final result = await settings.getRefreshRate();
      // assert
      expect(result, equals(3));
      verify(mockSettingsRepository.getRefreshRate());
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'setRefreshRate should forward request to the repository',
    () async {
      // act
      await settings.setRefreshRate(3);
      // assert
      verify(mockSettingsRepository.setRefreshRate(3));
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'getLastSelectedServer should get last selected server from settings',
    () async {
      // arrange
      when(mockSettingsRepository.getLastSelectedServer())
          .thenAnswer((_) async => tTautulliId);
      // act
      final result = await settings.getLastSelectedServer();
      // assert
      expect(result, equals(tTautulliId));
      verify(mockSettingsRepository.getLastSelectedServer());
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'setLastSelectedServer should forward request to the repository',
    () async {
      // act
      await settings.setLastSelectedServer(tTautulliId);
      // assert
      verify(mockSettingsRepository.setLastSelectedServer(tTautulliId));
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'getStatsType should get stats type from settings',
    () async {
      // arrange
      when(mockSettingsRepository.getStatsType())
          .thenAnswer((_) async => tStatsType);
      // act
      final result = await settings.getStatsType();
      // assert
      expect(result, equals(tStatsType));
      verify(mockSettingsRepository.getStatsType());
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );

  test(
    'setStatsType should forward request to the repository',
    () async {
      // act
      await settings.setStatsType(tStatsType);
      // assert
      verify(mockSettingsRepository.setStatsType(tStatsType));
      verifyNoMoreInteractions(mockSettingsRepository);
    },
  );
}
