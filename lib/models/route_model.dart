class RouteDocument {
  final String name;
  final String type;
  final bool isRequired;

  const RouteDocument({
    required this.name,
    required this.type,
    required this.isRequired,
  });

  factory RouteDocument.fromJson(Map<String, dynamic> j) => RouteDocument(
        name: j['name'] as String,
        type: j['type'] as String,
        isRequired: j['is_required'] as bool,
      );
}

class RouteStep {
  final String id;
  final int order;
  final String title;
  final String description;
  final String? entityName;
  final String? entityAddress;
  final int estimatedDays;
  final double estimatedCostCop;
  final bool isOptional;
  final List<RouteDocument> documents;

  const RouteStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    this.entityName,
    this.entityAddress,
    required this.estimatedDays,
    required this.estimatedCostCop,
    required this.isOptional,
    required this.documents,
  });

  factory RouteStep.fromJson(Map<String, dynamic> j) => RouteStep(
        id: j['id'] as String,
        order: j['order'] as int,
        title: j['title'] as String,
        description: j['description'] as String,
        entityName: j['entity_name'] as String?,
        entityAddress: j['entity_address'] as String?,
        estimatedDays: j['estimated_days'] as int,
        estimatedCostCop: (j['estimated_cost_cop'] as num).toDouble(),
        isOptional: j['is_optional'] as bool,
        documents: (j['documents'] as List? ?? [])
            .map((d) => RouteDocument.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class RouteModel {
  final String id;
  final String name;
  final String description;
  final String tramiteType;
  final String targetEntity;
  final int estimatedDays;
  final double estimatedCostCop;
  final String normativaRef;
  final int? totalSteps;
  final List<RouteStep>? steps;

  const RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tramiteType,
    required this.targetEntity,
    required this.estimatedDays,
    required this.estimatedCostCop,
    required this.normativaRef,
    this.totalSteps,
    this.steps,
  });

  factory RouteModel.fromJson(Map<String, dynamic> j) => RouteModel(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        tramiteType: j['tramite_type'] as String,
        targetEntity: j['target_entity'] as String,
        estimatedDays: j['estimated_days'] as int,
        estimatedCostCop: (j['estimated_cost_cop'] as num).toDouble(),
        normativaRef: j['normativa_ref'] as String,
        totalSteps: j['total_steps'] as int?,
        steps: j['steps'] != null
            ? (j['steps'] as List)
                .map((s) => RouteStep.fromJson(s as Map<String, dynamic>))
                .toList()
            : null,
      );
}

class TrackerModel {
  final String trackerId;
  final String routeId;
  final String routeName;
  final String tramiteType;
  final int totalSteps;
  final int estimatedDays;
  final double estimatedCostCop;

  const TrackerModel({
    required this.trackerId,
    required this.routeId,
    required this.routeName,
    required this.tramiteType,
    required this.totalSteps,
    required this.estimatedDays,
    required this.estimatedCostCop,
  });

  factory TrackerModel.fromJson(Map<String, dynamic> j) => TrackerModel(
        trackerId: j['tracker_id'] as String,
        routeId: j['route_id'] as String,
        routeName: j['route_name'] as String,
        tramiteType: j['tramite_type'] as String,
        totalSteps: j['total_steps'] as int,
        estimatedDays: j['estimated_days'] as int,
        estimatedCostCop: (j['estimated_cost_cop'] as num).toDouble(),
      );
}
