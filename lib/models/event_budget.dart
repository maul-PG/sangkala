class EventBudget {
  final String id;
  final String eventId;
  final String itemName;
  final double estimatedCost;
  final double actualCost;
  final int quantity;
  final DateTime createdAt;

  const EventBudget({
    required this.id,
    required this.eventId,
    required this.itemName,
    required this.estimatedCost,
    required this.actualCost,
    required this.quantity,
    required this.createdAt,
  });

  double get totalEstimated => estimatedCost * quantity;
  double get totalActual => actualCost * quantity;

  factory EventBudget.fromJson(Map<String, dynamic> json) => EventBudget(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        itemName: json['item_name'] as String,
        estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
        actualCost: (json['actual_cost'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'item_name': itemName,
        'estimated_cost': estimatedCost,
        'actual_cost': actualCost,
        'quantity': quantity,
      };

  EventBudget copyWith({
    String? itemName,
    double? estimatedCost,
    double? actualCost,
    int? quantity,
  }) =>
      EventBudget(
        id: id,
        eventId: eventId,
        itemName: itemName ?? this.itemName,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        actualCost: actualCost ?? this.actualCost,
        quantity: quantity ?? this.quantity,
        createdAt: createdAt,
      );
}
