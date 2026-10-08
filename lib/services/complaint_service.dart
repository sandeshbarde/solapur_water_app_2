import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';
import 'api_client.dart';

class ComplaintService extends ChangeNotifier {
  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;

  ComplaintService() {
    fetchComplaints();
  }

  List<ComplaintModel> get complaints => List.unmodifiable(_complaints);
  bool get isLoading => _isLoading;
  
  List<ComplaintModel> get pendingComplaints => 
      _complaints.where((c) => c.status == ComplaintStatus.pending).toList();

  Future<void> fetchComplaints({String? ward, String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = '/complaints';
      final queryParams = <String>[];
      if (ward != null) queryParams.add('ward=$ward');
      if (status != null) queryParams.add('status=$status');
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await ApiClient.get(endpoint);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['complaints'] as List? ?? [];
        _complaints = list.map((c) => ComplaintModel.fromJson(c)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Failed fetching complaints: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitComplaint({
    required String category,
    required String description,
    required String ward,
    required String address,
    required double latitude,
    required double longitude,
    List<File>? files,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final streamedResponse = await ApiClient.postMultipart(
        '/complaints',
        fields: {
          'category': category,
          'description': description,
          'ward': ward,
          'address': address,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
        files: files,
      );

      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        await fetchComplaints();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Failed submitting complaint: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateStatus(String complaintId, String newStatus, {String note = '', String? assignedOfficer}) async {
    try {
      final response = await ApiClient.patch(
        '/complaints/$complaintId/status',
        body: {
          'status': newStatus,
          'note': note,
          'assignedOfficer': assignedOfficer,
        },
      );
      if (response.statusCode == 200) {
        await fetchComplaints();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Failed updating complaint status: $e');
    }
    return false;
  }
}
