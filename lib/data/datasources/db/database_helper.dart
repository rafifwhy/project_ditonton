import 'dart:async';

import 'package:ditonton/data/models/movie/movie_table.dart';
import 'package:ditonton/data/models/tv_Series/tv_table.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      _database = await _initDb();
    }
    return _database;
  }

  static const String _tblMovieWatchList = 'movieWatchList';
  static const String _tblTvWatchList = 'tvWatchList';
  static const String _tblCache = 'cache';

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/ditontonv2.db';

    var db = await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE  $_tblMovieWatchList (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE $_tblTvWatchList (
        id INTEGER PRIMARY KEY,
        name TEXT,
        overview TEXT,
        posterPath TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE  $_tblCache (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT,
        category TEXT
      );
    ''');
  }

  Future<void> insertCacheTransaction(
      List<MovieTable> movies, String category) async {
    final db = await database;
    db!.transaction((txn) async {
      for (final movie in movies) {
        final movieJson = movie.toJson();
        movieJson['category'] = category;
        txn.insert(_tblCache, movieJson);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCacheMovies(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(
      _tblCache,
      where: 'category = ?',
      whereArgs: [category],
    );

    return results;
  }

  Future<int> clearCache(String category) async {
    final db = await database;
    return await db!.delete(
      _tblCache,
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<int> insertMovieWatchlist(MovieTable movie) async {
    final db = await database;
    return await db!.insert(_tblMovieWatchList, movie.toJson());
  }

  Future<int> insertTvWatchlist(TvTable tv) async {
    final db = await database;
    return await db!.insert(_tblTvWatchList, tv.toJson());
  }

  Future<int> removeMovieWatchlist(MovieTable movie) async {
    final db = await database;
    return await db!.delete(
      _tblMovieWatchList,
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> removeTvWatchlist(TvTable tv) async {
    final db = await database;
    return await db!.delete(
      _tblTvWatchList,
      where: 'id = ?',
      whereArgs: [tv.id],
    );
  }

  Future<Map<String, dynamic>?> getMovieById(int id) async {
    final db = await database;
    final results = await db!.query(
      _tblMovieWatchList,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTvById(int id) async {
    final db = await database;
    final results = await db!.query(
      _tblTvWatchList,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlistMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> results =
        await db!.query(_tblMovieWatchList);

    return results;
  }

  Future<List<Map<String, dynamic>>> getWatchlistTv() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(_tblTvWatchList);

    return results;
  }
}
