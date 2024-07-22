import 'package:dio/dio.dart';
import 'package:google_apis_flutter/core/utils/constants/api_constants.dart';

class ApiServices {
  final Dio _dio;

  ApiServices(this._dio);

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get("$baseUrl$endpoint");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("$baseUrl$endpoint", data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put("$baseUrl$endpoint", data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete("$baseUrl$endpoint");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
