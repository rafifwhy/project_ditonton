import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/entities/tv_series/tv.dart';
import 'package:ditonton/domain/repositories/tv_repository.dart';

class GetTvWatchlist {
  final TvRepository repository;

  GetTvWatchlist(this.repository);

  Future<Either<Failure, List<Tv>>> execute() {
    return repository.getTvWatchlist();
  }
}
