import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class AnimatedMeshGradientView extends StatelessWidget {
  const AnimatedMeshGradientView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: AnimatedMeshGradient(
        colors: const [
          Colors.deepOrange,
          Colors.pinkAccent,
          Colors.yellow,
          Colors.white,
        ],
        options: AnimatedMeshGradientOptions(speed: 0.5),
      ),
    );
  }
}
