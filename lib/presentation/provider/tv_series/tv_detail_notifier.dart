import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series/tv.dart';
import 'package:ditonton/domain/entities/tv_series/tv_detail.dart';
import 'package:ditonton/domain/usecases/tv_series/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/tv_series/get_tv_recomendations.dart';
import 'package:ditonton/domain/usecases/tv_series/get_tv_watchlist_status.dart';
import 'package:ditonton/domain/usecases/tv_series/remove_tv_watchlist.dart';
import 'package:ditonton/domain/usecases/tv_series/save_tv_watchlist.dart';
import 'package:flutter/material.dart';

class TvDetailNotifier extends ChangeNotifier {
  static const tvWatchlistAddSuccessMessage = 'Added to Watchlist';
  static const tvWatchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetTvDetail getTvDetail;
  final GetTvRecommendations getTvRecommendations;
  final GetTvWatchListStatus getTvWatchListStatus;
  final SaveTvWatchlist saveTvWatchlist;
  final RemoveTvWatchlist removeTvWatchlist;

  TvDetailNotifier({
    required this.getTvDetail,
    required this.getTvRecommendations,
    required this.getTvWatchListStatus,
    required this.saveTvWatchlist,
    required this.removeTvWatchlist,
  });

  late TvDetail _tvDetail;
  TvDetail get tvDetail => _tvDetail;

  RequestState _tvState = RequestState.Empty;
  RequestState get tvState => _tvState;

  List<Tv> _tvRecommendations = [];
  List<Tv> get tvRecommendations => _tvRecommendations;

  RequestState _tvRecommendationsState = RequestState.Empty;
  RequestState get tvRecommendationsState => _tvRecommendationsState;

  String _message = '';
  String get message => _message;

  bool _tvIsAddedtoWatchlist = false;
  bool get tvIsAddedtoWatchlist => _tvIsAddedtoWatchlist;

  Future<void> fetchTvDetail(int id) async {
    _tvState = RequestState.Loading;
    notifyListeners();
    final detailTvResult = await getTvDetail.execute(id);
    final recommendationsTvResult = await getTvRecommendations.execute(id);
    detailTvResult.fold(
      (failure) {
        _tvState = RequestState.Error;
        _message = failure.message;
        notifyListeners();
      },
      (tv) {
        _tvRecommendationsState = RequestState.Loading;
        _tvDetail = tv;
        recommendationsTvResult.fold(
          (failure) {
            _tvRecommendationsState = RequestState.Error;
            _message = failure.message;
          },
          (tvSeries) {
            _tvRecommendationsState = RequestState.Loaded;
            _tvRecommendations = tvSeries;
          },
        );
        _tvState = RequestState.Loaded;
        notifyListeners();
      },
    );
  }

  String _tvWatchlistMessage = '';
  String get tvWatchlistMessage => _tvWatchlistMessage;

  Future<void> addTvWatchlist(TvDetail tvDetail) async {
    final result = await saveTvWatchlist.execute(tvDetail);

    await result.fold(
      (failure) async {
        _tvWatchlistMessage = failure.message;
      },
      (succsessMessage) async {
        _tvWatchlistMessage = succsessMessage;
      },
    );

    await loadTvWatchlistStatus(tvDetail.id);
  }

  Future<void> removeTvFromWatchlist(TvDetail tvDetail) async {
    final result = await removeTvWatchlist.execute(tvDetail);

    await result.fold(
      (failure) async {
        _tvWatchlistMessage = failure.message;
      },
      (successMessage) async {
        _tvWatchlistMessage = successMessage;
      },
    );

    await loadTvWatchlistStatus(tvDetail.id);
  }

  Future<void> loadTvWatchlistStatus(int id) async {
    final result = await getTvWatchListStatus.execute(id);
    _tvIsAddedtoWatchlist = result;
    notifyListeners();
  }
}
