import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv_series/tv.dart';
import 'package:ditonton/domain/usecases/tv_series/get_popular_tv.dart';
import 'package:flutter/material.dart';

class TvPopularNotifier extends ChangeNotifier {
  final GetPopularTv getPopularTv;

  TvPopularNotifier(this.getPopularTv);

  RequestState _state = RequestState.Empty;
  RequestState get state => _state;

  List<Tv> _tvSeries = [];
  List<Tv> get tvSeries => _tvSeries;

  String _message = '';
  String get message => _message;

  Future<void> fetchPopularTvSeries() async {
    _state = RequestState.Loading;
    notifyListeners();

    final result = await getPopularTv.execute();

    result.fold((failure) {
      _message = failure.message;
      _state = RequestState.Error;
      notifyListeners();
    }, (tvData) {
      _tvSeries = tvData;
      _state = RequestState.Loaded;
      notifyListeners();
    });
  }
}
