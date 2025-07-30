import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int maxImages;
  final void Function(int index, String imageUrl)? onImageTap;

  /// Creates a staggered grid gallery
  ///
  /// [imageUrls] is the list of image URLs or asset paths.
  /// [maxImages] limits the number of images displayed (default: 5).
  /// [onImageTap] callback when an image is tapped.
  const StaggeredImageGallery({
    super.key,
    required this.imageUrls,
    this.maxImages = 5,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayedImages = imageUrls.take(maxImages).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Let parent scroll
        crossAxisCount: 2, // 2 columns
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: displayedImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (onImageTap != null) {
                onImageTap!(index, displayedImages[index]);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                displayedImages[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
