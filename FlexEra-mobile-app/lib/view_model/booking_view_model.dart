import 'package:dio/dio.dart';
import 'package:flexera/core/network/constants.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/network/end_points.dart';
import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flutter/material.dart';

class BookingViewModel extends ChangeNotifier {
  List<BookingModel> _allDoctors = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<BookingModel> get allDoctors => _allDoctors;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  List<BookingModel> get topDoctors => _allDoctors.take(4).toList();

  List<BookingModel> searchDoctors(String query) {
    if (query.isEmpty) return _allDoctors;
    return _allDoctors
        .where((doc) => doc.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> fetchAllDoctors() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      Response response = await DioHelper.getData(
        url: EndPoints.doctors,
        token: token,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = [];

        if (response.data is List) {
          data = response.data;
        } else if (response.data['doctors'] != null) {
          data = response.data['doctors'];
        } else if (response.data['data'] != null) {
          data = response.data['data'];
        }

        _allDoctors = data.map((item) => BookingModel.fromJson(item)).toList();

        debugPrint("Doctors fetched successfully: ${_allDoctors.length}");
      }
    } on DioException catch (e) {
      _errorMessage = "Connection error";
      if (e.response != null) {
        _errorMessage = e.response?.data['message'] ?? _errorMessage;
      }
      debugPrint("Error fetching doctors: $e");
    } catch (e) {
      _errorMessage = "Something went wrong";
      debugPrint("Generic Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
