import 'package:flutter/material.dart';

import '../models/season_model.dart';
import '../repositiory/season_repository.dart';

class SeasonProvider extends ChangeNotifier {
  final SeasonRepository _repository;

  List<Season> _seasons = [];
  bool _isLoading = false;
  String? _errorMessage;

  SeasonProvider(this._repository);

  List<Season> get seasons => _seasons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSeasons(String id) async {
    // print('id==========> $id');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _seasons = await _repository.fetchSeasons(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching seasons: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
