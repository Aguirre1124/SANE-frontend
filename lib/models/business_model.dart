class BusinessModel {
  final String id;
  final String tradeName;
  final String? riskLevel;
  final String? tramiteType;
  final String? targetEntity;

  const BusinessModel({
    required this.id,
    required this.tradeName,
    this.riskLevel,
    this.tramiteType,
    this.targetEntity,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> j) => BusinessModel(
        id: j['id'] as String,
        tradeName: j['trade_name'] as String,
        riskLevel: j['risk_level'] as String?,
        tramiteType: j['tramite_type'] as String?,
        targetEntity: j['target_entity'] as String?,
      );
}
