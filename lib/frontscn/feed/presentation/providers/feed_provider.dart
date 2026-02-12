import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frijofeeds/core/constants/api_endpoints.dart';
import 'package:frijofeeds/frontscn/home/data/homemodel/feed_model.dart';

class FeedProvider extends ChangeNotifier {
  final Dio _dio;
  List<Feed> _myFeeds = [];
  bool _isLoading = false;
  double _uploadProgress = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _lastErrorMessage;

  FeedProvider(this._dio);

  List<Feed> get myFeeds => _myFeeds;
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  bool get hasMore => _hasMore;
  String? get lastErrorMessage => _lastErrorMessage;

  Future<void> fetchMyFeeds({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _myFeeds = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiEndpoints.myFeed,
        queryParameters: {'page': _currentPage},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final List data = response.data['data'];
        final List<Feed> newFeeds = data.map((e) => Feed.fromJson(e)).toList();

        if (newFeeds.isEmpty) {
          _hasMore = false;
        } else {
          _myFeeds.addAll(newFeeds);
          _currentPage++;
        }
      }
    } on DioException catch (e) {
      debugPrint('My Feeds Fetch Error: ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching my feeds: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadFeed({
    required String videoPath,
    required String imagePath,
    required String description,
    required List<String> categoryIds,
  }) async {
    _isLoading = true;
    _uploadProgress = 0;
    notifyListeners();

    try {
      debugPrint('Uploading to ${ApiEndpoints.myFeed}');
      debugPrint(
        'Fields: desc: $description, category: [${categoryIds.join(",")}]',
      );

      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(videoPath),
        'image': await MultipartFile.fromFile(imagePath),
        'desc': description,
        'category': "[${categoryIds.join(',')}]",
      });

      final response = await _dio.post(
        ApiEndpoints.myFeed,
        data: formData,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _lastErrorMessage = e.response?.data?['message'] ?? e.message;
      debugPrint('Upload Error Body: ${e.response?.data}');
    } catch (e) {
      _lastErrorMessage = e.toString();
      debugPrint('Upload Error: $e');
    }

    _isLoading = false;
    _uploadProgress = 0;
    notifyListeners();
    return false;
  }
}
