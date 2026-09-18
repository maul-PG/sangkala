class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final String status;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        eventDate: DateTime.parse(json['event_date'] as String),
        location: json['location'] as String? ?? '',
        status: json['status'] as String? ?? 'Planning',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String().split('T').first,
        'location': location,
        'status': status,
      };

  Event copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? status,
  }) =>
      Event(
        id: id,
        userId: userId,
        title: title ?? this.title,
        description: description ?? this.description,
        eventDate: eventDate ?? this.eventDate,
        location: location ?? this.location,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
