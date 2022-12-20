import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series/tv.dart';
import 'package:ditonton/domain/usecases/tv_series/get_tv_watchlist.dart';
import 'package:flutter/material.dart';

class TvWatchlistNotifier extends ChangeNotifier {
  var _watchlistTv = <Tv>[];
  List<Tv> get watchlistTv => _watchlistTv;

  var _watchlistTvState = RequestState.Empty;
  RequestState get watchlistTvState => _watchlistTvState;

  String _message = '';
  String get message => _message;

  TvWatchlistNotifier({required this.getTvWatchlist});

  final GetTvWatchlist getTvWatchlist;

  Future<void> fetchWatchlistTvSeries() async {
    _watchlistTvState = RequestState.Loading;
    notifyListeners();

    final result = await getTvWatchlist.execute();
    result.fold(
      (failure) {
        _watchlistTvState = RequestState.Error;
        _message = failure.message;
        notifyListeners();
      },
      (tvData) {
        _watchlistTvState = RequestState.Loaded;
        _watchlistTv = tvData;
        notifyListeners();
      },
    );
  }
}
