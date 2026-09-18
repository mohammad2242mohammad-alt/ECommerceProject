import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConstants.mediaUrl(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: width,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.45),
        child: resolved.isEmpty
            ? const Center(
                child: Icon(Icons.image_outlined, size: 42, color: Colors.grey),
              )
            : Image.network(
                resolved,
                fit: fit,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}
