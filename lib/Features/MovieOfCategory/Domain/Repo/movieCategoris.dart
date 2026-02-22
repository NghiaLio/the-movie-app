// ignore_for_file: camel_case_types

import '../Entities/MovieOfCategories.dart';

import '../Entities/Categories.dart';

abstract class movieCategoriesRepo{
  Future<ListCategories?> getListCategories();
  Future<ListMovieOfCategories?> getListMovieCategories(String slug);
}