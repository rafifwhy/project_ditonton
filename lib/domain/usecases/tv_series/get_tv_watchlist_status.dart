import 'package:ditonton/domain/repositories/tv_repository.dart';

class GetWatchListStatusTvls {
  final TvRepository repository;

  GetWatchListStatusTvls(this.repository);

  Future<bool> execute(int id) async {
    return repository.isAddedToTvWatchlist(id);
  }
}
