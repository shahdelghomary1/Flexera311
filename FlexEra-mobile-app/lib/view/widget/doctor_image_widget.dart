import 'package:flutter/material.dart';

class DoctorImageWidget extends StatelessWidget {
  final String imageUrl;
  final String defaultImage;
  final BoxFit fit;

  const DoctorImageWidget({
    super.key,
    required this.imageUrl,
    this.defaultImage = "assets/images/defult_doc.png",
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Image.asset(
        defaultImage,
        fit: fit,
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          defaultImage,
          fit: fit,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
