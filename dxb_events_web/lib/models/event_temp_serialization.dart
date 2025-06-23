// Temporary serialization methods for new models
// This file provides placeholder serialization until build_runner generates the actual ones

import 'event.dart';

// Placeholder fromJson methods for new models
Map<String, dynamic> _$SocialMediaLinksToJson(SocialMediaLinks instance) => {
  'instagram': instance.instagram,
  'facebook': instance.facebook,
  'twitter': instance.twitter,
  'tiktok': instance.tiktok,
  'youtube': instance.youtube,
  'whatsapp': instance.whatsapp,
  'telegram': instance.telegram,
};

SocialMediaLinks _$SocialMediaLinksFromJson(Map<String, dynamic> json) => SocialMediaLinks(
  instagram: json['instagram'] as String?,
  facebook: json['facebook'] as String?,
  twitter: json['twitter'] as String?,
  tiktok: json['tiktok'] as String?,
  youtube: json['youtube'] as String?,
  whatsapp: json['whatsapp'] as String?,
  telegram: json['telegram'] as String?,
);

Map<String, dynamic> _$QualityMetricsToJson(QualityMetrics instance) => {
  'extraction_confidence': instance.extractionConfidence,
  'data_completeness': instance.dataCompleteness,
  'source_reliability': instance.sourceReliability,
  'last_verified': instance.lastVerified,
  'extraction_method': instance.extractionMethod,
  'validation_warnings': instance.validationWarnings,
};

QualityMetrics _$QualityMetricsFromJson(Map<String, dynamic> json) => QualityMetrics(
  extractionConfidence: (json['extraction_confidence'] as num).toDouble(),
  dataCompleteness: (json['data_completeness'] as num).toDouble(),
  sourceReliability: json['source_reliability'] as String,
  lastVerified: json['last_verified'] as String,
  extractionMethod: json['extraction_method'] as String,
  validationWarnings: (json['validation_warnings'] as List<dynamic>).cast<String>(),
);