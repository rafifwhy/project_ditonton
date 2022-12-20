import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series/tv.dart';
import 'package:ditonton/domain/usecases/tv_series/search_tv.dart';
import 'package:flutter/material.dart';

class TvSearchNotifier extends ChangeNotifier {
  final SearchTv searchTvSeries;

  TvSearchNotifier({required this.searchTvSeries});

  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  List<Tv> _searchTvResult = [];
  List<Tv> get searchTvResult => _searchTvResult;

  String _message = '';
  String get message => _message;

  Future<void> fetchTvSearch(String query) async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await searchTvSeries.execute(query);
    result.fold(
      (failure) {
        _message = failure.message;
        _state = RequestState.Error;
        notifyListeners();
      },
      (data) {
        _searchTvResult = data;
        _state = RequestState.Loaded;
        notifyListeners();
      },
    );
  }
}
