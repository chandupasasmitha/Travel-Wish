import 'package:flutter/material.dart';

// Your ItemModel (replace with actual model if needed)
class ItemModel {
  final String url;
  final String id;

  ItemModel({required this.url, required this.id});

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      url: json['url'],
      id: json['_id'],
    );
  }
}

// Widget that extracts URLs and passes them to a builder
class UrlExtractorWidget extends StatelessWidget {
  final List<ItemModel> items;
  final Widget Function(BuildContext, List<String>) builder;

  const UrlExtractorWidget({
    Key? key,
    required this.items,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract URLs
    List<String> urls = items.map((item) => item.url).toList();

    return builder(context, urls);
  }
}
