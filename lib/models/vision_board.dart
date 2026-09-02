import 'package:flutter/material.dart';

class GoalBlock {
  final String id;
  final String title;
  final String category;
  final String bgImageUrl;
  final int tintValue;
  final String quote;
  final String targetDate;
  final String milestone;

  GoalBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.bgImageUrl,
    required this.tintValue,
    required this.quote,
    this.targetDate = '',
    this.milestone = '',
  });

  Color get tint => Color(tintValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'bgImageUrl': bgImageUrl,
      'tintValue': tintValue,
      'quote': quote,
      'targetDate': targetDate,
      'milestone': milestone,
    };
  }

  factory GoalBlock.fromJson(Map<String, dynamic> json) {
    return GoalBlock(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Mindset',
      bgImageUrl: json['bgImageUrl'] as String? ?? 'assets/images/onboarding_archway_sun.jpg',
      tintValue: json['tintValue'] as int? ?? 0xFF8A85A0,
      quote: json['quote'] as String? ?? '',
      targetDate: json['targetDate'] as String? ?? '',
      milestone: json['milestone'] as String? ?? '',
    );
  }

  GoalBlock copyWith({
    String? id,
    String? title,
    String? category,
    String? bgImageUrl,
    int? tintValue,
    String? quote,
    String? targetDate,
    String? milestone,
  }) {
    return GoalBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      bgImageUrl: bgImageUrl ?? this.bgImageUrl,
      tintValue: tintValue ?? this.tintValue,
      quote: quote ?? this.quote,
      targetDate: targetDate ?? this.targetDate,
      milestone: milestone ?? this.milestone,
    );
  }
}

class VisionBoard {
  final String id;
  final String title;
  final String template;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<GoalBlock> blocks;

  VisionBoard({
    required this.id,
    required this.title,
    this.template = '4 Blocks',
    required this.createdAt,
    required this.lastModified,
    this.blocks = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'template': template,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'blocks': blocks.map((b) => b.toJson()).toList(),
    };
  }

  factory VisionBoard.fromJson(Map<String, dynamic> json) {
    return VisionBoard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'My Vision Board',
      template: json['template'] as String? ?? '4 Blocks',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified']) ?? DateTime.now()
          : DateTime.now(),
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => GoalBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  VisionBoard copyWith({
    String? id,
    String? title,
    String? template,
    DateTime? createdAt,
    DateTime? lastModified,
    List<GoalBlock>? blocks,
  }) {
    return VisionBoard(
      id: id ?? this.id,
      title: title ?? this.title,
      template: template ?? this.template,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      blocks: blocks ?? this.blocks,
    );
  }
}
