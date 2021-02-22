import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tautulli_remote/core/api/tautulli_api/tautulli_api.dart'
    as tautulliApi;
import 'package:tautulli_remote/features/synced_items/data/datasources/delete_synced_item_data_source.dart';

class MockDeleteSyncedItem extends Mock
    implements tautulliApi.DeleteSyncedItem {}

void main() {
  DeleteSyncedItemDataSourceImpl dataSource;
  MockDeleteSyncedItem mockApiDeleteSyncedItem;

  setUp(() {
    mockApiDeleteSyncedItem = MockDeleteSyncedItem();
    dataSource = DeleteSyncedItemDataSourceImpl(
      apiDeleteSyncedItem: mockApiDeleteSyncedItem,
    );
  });

  final String tTautulliId = 'jkl';
  final String tClientId = 'abc';
  final int tSyncId = 123;

  final Map<String, dynamic> successMap = {
    'response': {
      'result': 'success',
    }
  };

  final Map<String, dynamic> failureMap = {
    'response': {
      'result': 'error',
    }
  };

  test(
    'should call [deleteSyncedItem] from TautulliApi',
    () async {
      // arrange
      when(
        mockApiDeleteSyncedItem(
          tautulliId: anyNamed('tautulliId'),
          clientId: anyNamed('clientId'),
          syncId: anyNamed('syncId'),
        ),
      ).thenAnswer((_) async => successMap);
      // act
      await dataSource(
        tautulliId: tTautulliId,
        clientId: tClientId,
        syncId: tSyncId,
      );
      // assert
      verify(
        mockApiDeleteSyncedItem(
          tautulliId: tTautulliId,
          clientId: tClientId,
          syncId: tSyncId,
        ),
      );
    },
  );

  test(
    'should return true is deletion is successful',
    () async {
      // arrange
      when(
        mockApiDeleteSyncedItem(
          tautulliId: anyNamed('tautulliId'),
          clientId: anyNamed('clientId'),
          syncId: anyNamed('syncId'),
        ),
      ).thenAnswer((_) async => successMap);
      // act
      final result = await dataSource(
        tautulliId: tTautulliId,
        clientId: tClientId,
        syncId: tSyncId,
      );
      // assert
      expect(result, equals(true));
    },
  );

  test(
    'should return false is deletion fails',
    () async {
      // arrange
      when(
        mockApiDeleteSyncedItem(
          tautulliId: anyNamed('tautulliId'),
          clientId: anyNamed('clientId'),
          syncId: anyNamed('syncId'),
        ),
      ).thenAnswer((_) async => failureMap);
      // act
      final result = await dataSource(
        tautulliId: tTautulliId,
        clientId: tClientId,
        syncId: tSyncId,
      );
      // assert
      expect(result, equals(false));
    },
  );
}
