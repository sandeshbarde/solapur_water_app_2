enum ComplaintStatus { pending, inProgress, resolved, rejected }

class ComplaintAttachment {
  final String url;
  final String name;
  final String type;
  final int size;

  ComplaintAttachment({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
  });

  factory ComplaintAttachment.fromJson(Map<String, dynamic> json) {
    return ComplaintAttachment(
      url: json['url'] ?? '',
      name: json['name'] ?? 'file',
      type: json['type'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'type': type,
    'size': size,
  };
}

class ComplaintTimelineItem {
  final String status;
  final int timestamp;
  final String note;

  ComplaintTimelineItem({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  factory ComplaintTimelineItem.fromJson(Map<String, dynamic> json) {
    return ComplaintTimelineItem(
      status: json['status'] ?? 'pending',
      timestamp: json['timestamp'] ?? 0,
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp,
    'note': note,
  };
}

class ComplaintModel {
  final String id;
  final String userId;
  final String? citizenName;
  final String? citizenPhone;
  final String category;
  final String description;
  final String ward;
  final double latitude;
  final double longitude;
  final String address;
  final String? photoUrl;
  final String? assignedOfficer;
  final String? officerNote;
  final List<ComplaintAttachment> attachments;
  final List<ComplaintTimelineItem> timeline;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ComplaintStatus status;

  ComplaintModel({
    required this.id,
    required this.userId,
    this.citizenName,
    this.citizenPhone,
    required this.category,
    required this.description,
    this.ward = 'Ward 1 (Ashok Chowk)',
    required this.latitude,
    required this.longitude,
    required this.address,
    this.photoUrl,
    this.assignedOfficer,
    this.officerNote,
    this.attachments = const [],
    this.timeline = const [],
    required this.createdAt,
    this.updatedAt,
    this.status = ComplaintStatus.pending,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    ComplaintStatus parseStatus(String? s) {
      switch (s) {
        case 'inProgress':
          return ComplaintStatus.inProgress;
        case 'resolved':
          return ComplaintStatus.resolved;
        case 'rejected':
          return ComplaintStatus.rejected;
        default:
          return ComplaintStatus.pending;
      }
    }

    final rawAttachments = json['attachments'] as List? ?? [];
    final rawTimeline = json['timeline'] as List? ?? [];

    return ComplaintModel(
      id: json['id'] ?? '',
      userId: json['userId']?.toString() ?? '',
      citizenName: json['citizenName'],
      citizenPhone: json['citizenPhone'],
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      ward: json['ward'] ?? 'Ward 1 (Ashok Chowk)',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.6599,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 75.9064,
      assignedOfficer: json['assignedOfficer'],
      officerNote: json['officerNote'],
      attachments: rawAttachments.map((a) => ComplaintAttachment.fromJson(a)).toList(),
      timeline: rawTimeline.map((t) => ComplaintTimelineItem.fromJson(t)).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int) * 1000)
          : DateTime.now(),
      status: parseStatus(json['status']),
    );
  }
}
