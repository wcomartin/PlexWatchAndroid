import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../repositories/delete_synced_item_repository.dart';

class DeleteSyncedItem {
  final DeleteSyncedItemRepository repository;

  DeleteSyncedItem({@required this.repository});

  Future<Either<Failure, bool>> call({
    @required String tautulliId,
    @required String clientId,
    @required int syncId,
  }) async {
    return await repository(
      tautulliId: tautulliId,
      clientId: clientId,
      syncId: syncId,
    );
  }
}
