// @dart=2.9

import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tautulli_remote/features/graphs/data/models/graph_data_model.dart';
import 'package:tautulli_remote/features/graphs/data/models/series_data_model.dart';
import 'package:tautulli_remote/features/graphs/domain/entities/series_data.dart';
import 'package:tautulli_remote/features/graphs/domain/repositories/graphs_repository.dart';
import 'package:tautulli_remote/features/graphs/domain/usecases/get_stream_type_by_top_10_platforms.dart';
import 'package:tautulli_remote/features/logging/domain/usecases/logging.dart';
import 'package:tautulli_remote/features/settings/domain/usecases/settings.dart';
import 'package:tautulli_remote/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tautulli_remote/features/onesignal/data/datasources/onesignal_data_source.dart';
import 'package:tautulli_remote/features/settings/domain/usecases/register_device.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockGraphsRepository extends Mock implements GraphsRepository {}

class MockSettings extends Mock implements Settings {}

class MockOnesignal extends Mock implements OneSignalDataSource {}

class MockRegisterDevice extends Mock implements RegisterDevice {}

class MockLogging extends Mock implements Logging {}

void main() {
  GetStreamTypeByTop10Platforms usecase;
  MockGraphsRepository mockGraphsRepository;
  MockSettings mockSettings;
  MockOnesignal mockOnesignal;
  MockRegisterDevice mockRegisterDevice;
  MockLogging mockLogging;
  SettingsBloc settingsBloc;

  setUp(() {
    mockGraphsRepository = MockGraphsRepository();
    usecase = GetStreamTypeByTop10Platforms(
      repository: mockGraphsRepository,
    );
    mockSettings = MockSettings();
    mockOnesignal = MockOnesignal();
    mockRegisterDevice = MockRegisterDevice();
    mockLogging = MockLogging();
    settingsBloc = SettingsBloc(
      settings: mockSettings,
      onesignal: mockOnesignal,
      registerDevice: mockRegisterDevice,
      logging: mockLogging,
    );
  });

  const String tTautulliId = 'jkl';

  final streamTypeByTop10PlatformsJson =
      json.decode(fixture('graphs_stream_type_by_top_10_platforms.json'));
  final List<String> tStreamTypeByTop10PlatformsCategories = List<String>.from(
    streamTypeByTop10PlatformsJson['response']['data']['categories'],
  );
  final List<SeriesData> tStreamTypeByTop10PlatformsSeriesDataList = [];
  streamTypeByTop10PlatformsJson['response']['data']['series'].forEach((item) {
    tStreamTypeByTop10PlatformsSeriesDataList
        .add(SeriesDataModel.fromJson(item));
  });
  final tStreamTypeByTop10PlatformsGraphData = GraphDataModel(
    categories: tStreamTypeByTop10PlatformsCategories,
    seriesDataList: tStreamTypeByTop10PlatformsSeriesDataList,
  );

  test(
    'should get GraphData from repository',
    () async {
      // arrange
      when(
        mockGraphsRepository.getStreamTypeByTop10Platforms(
          tautulliId: anyNamed('tautulliId'),
          timeRange: anyNamed('timeRange'),
          yAxis: anyNamed('yAxis'),
          userId: anyNamed('userId'),
          grouping: anyNamed('grouping'),
          settingsBloc: anyNamed('settingsBloc'),
        ),
      ).thenAnswer((_) async => Right(tStreamTypeByTop10PlatformsGraphData));
      // act
      final result = await usecase(
        tautulliId: tTautulliId,
        settingsBloc: settingsBloc,
      );
      // assert
      expect(result, equals(Right(tStreamTypeByTop10PlatformsGraphData)));
    },
  );
}
