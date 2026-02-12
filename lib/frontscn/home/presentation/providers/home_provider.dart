import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frijofeeds/core/constants/api_endpoints.dart';
import 'package:frijofeeds/frontscn/home/data/homemodel/category_model.dart';
import 'package:frijofeeds/frontscn/home/data/homemodel/feed_model.dart';

class HomeProvider extends ChangeNotifier {
  final Dio _dio;
  List<Category> _categories = [];
  List<Feed> _feeds = [];
  bool _isLoading = false;

  HomeProvider(this._dio);

  String _userName = "Maria";
  String? _userProfileImage;

  List<Category> get categories => _categories;
  List<Feed> get feeds => _feeds;
  String get userName => _userName;
  String? get userProfileImage => _userProfileImage;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categoryList);
      if (response.statusCode == 200 || response.statusCode == 202) {
        // category_list GET might still use 'data' or 'results', but let's check
        // for 'category_dict' as seen in the /api/home response.
        final List? data =
            response.data['data'] ??
            response.data['categories'] ??
            response.data['category_dict'];
        if (data != null) {
          _categories = data.map((e) => Category.fromJson(e)).toList();
          notifyListeners();
        }
      }
    } on DioException catch (e) {
      debugPrint('Categories Fetch Error: ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchHomeFeeds() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get(ApiEndpoints.home);
      if (response.statusCode == 200 || response.statusCode == 202) {
        // Extract root user data if available
        debugPrint('User data from API: ${response.data['user']}');
        if (response.data['user'] != null) {
          final userData = response.data['user'];
          debugPrint('User data type: ${userData.runtimeType}');
          if (userData is Map) {
            debugPrint('User data is Map: $userData');
            if (userData['name'] != null) {
              _userName = userData['name'];
              debugPrint('Set userName to: $_userName');
            }
            if (userData['image'] != null) {
              _userProfileImage = userData['image'];
              debugPrint('Set userProfileImage to: $_userProfileImage');
            }
          } else {
            debugPrint(
              'User data is not a Map, it is: ${userData.runtimeType}',
            );
          }
        } else {
          debugPrint('User data is null in API response');
        }

        final List data = response.data['results'];
        _feeds = data.map((e) => Feed.fromJson(e)).toList();

        // Also update categories from home response if available
        if (response.data['category_dict'] != null) {
          final List catData = response.data['category_dict'];
          final List<Category> apiCats = catData
              .map((e) => Category.fromJson(e))
              .toList();

          // Merge with existing categories and sort/filter
          final Map<String, Category> uniqueCats = {};
          for (var c in [...apiCats, ..._categories]) {
            uniqueCats[c.id] = c;
          }

          _categories = uniqueCats.values.toList();

          // Custom sort order for mockup: Explore (0), Trending (0.0), All Categories (0.01)
          _categories.sort((a, b) {
            final order = {'0': 0, '0.0': 1, '0.01': 2};
            final aOrder = order[a.id] ?? 999;
            final bOrder = order[b.id] ?? 999;
            return aOrder.compareTo(bOrder);
          });
        }
      }
    } on DioException catch (e) {
      debugPrint('Feeds Fetch Error: ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching feeds: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
