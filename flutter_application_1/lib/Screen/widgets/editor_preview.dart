import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';

class TextLayer {
  String text;
  Offset position;
  double fontSize;
  Color color;

  TextLayer({
    required this.text,
    required this.position,
    this.fontSize = 18,
    this.color = Colors.white,
  });
}

class StickerLayer {
  String url;
  Offset position;
  double scale;

  StickerLayer({required this.url, required this.position, this.scale = 1.0});
}

class DrawStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawStroke({
    required this.points,
    this.color = Colors.yellow,
    this.width = 4,
  });
}

class EditorPreview extends StatefulWidget {
  final String imageUrl;
  final List<TextLayer> textLayers;
  final List<StickerLayer> stickerLayers;
  final List<DrawStroke> strokes;
  final ColorFilter? filter;
  final void Function(int index, TextLayer layer)? onUpdateText;
  final void Function(int index, StickerLayer layer)? onUpdateSticker;

  const EditorPreview({
    super.key,
    required this.imageUrl,
    required this.textLayers,
    required this.stickerLayers,
    required this.strokes,
    this.filter,
    this.onUpdateText,
    this.onUpdateSticker,
  });

  @override
  State<EditorPreview> createState() => _EditorPreviewState();
}

class _EditorPreviewState extends State<EditorPreview> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.filter != null)
                  ColorFiltered(
                    colorFilter: widget.filter!,
                    child: _buildImage(widget.imageUrl),
                  )
                else
                  _buildImage(widget.imageUrl),

                CustomPaint(
                  painter: _DrawPainter(widget.strokes),
                  size: Size.infinite,
                ),

                ...widget.stickerLayers.asMap().entries.map((e) {
                  final i = e.key;
                  final s = e.value;
                  return _buildSticker(i, s);
                }),

                ...widget.textLayers.asMap().entries.map((e) {
                  final i = e.key;
                  final t = e.value;
                  return _buildText(i, t);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSticker(int index, StickerLayer layer) {
    return Positioned(
      left: layer.position.dx,
      top: layer.position.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final updated = StickerLayer(
            url: layer.url,
            position: layer.position + d.delta,
            scale: layer.scale,
          );
          widget.onUpdateSticker?.call(index, updated);
        },
        child: Transform.scale(
          scale: layer.scale,
          child: Image.network(layer.url, width: 120, height: 120),
        ),
      ),
    );
  }

  Widget _buildText(int index, TextLayer layer) {
    return Positioned(
      left: layer.position.dx,
      top: layer.position.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final updated = TextLayer(
            text: layer.text,
            position: layer.position + d.delta,
            fontSize: layer.fontSize,
            color: layer.color,
          );
          widget.onUpdateText?.call(index, updated);
        },
        child: Text(
          layer.text,
          style: TextStyle(
            color: layer.color,
            fontSize: layer.fontSize,
            shadows: [
              const Shadow(
                blurRadius: 4,
                color: Colors.black45,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    final isNetwork = imageUrl.startsWith('http');
    return isNetwork
        ? Image.network(imageUrl, fit: BoxFit.cover)
        : Image.file(File(imageUrl), fit: BoxFit.cover);
  }
}

class _DrawPainter extends CustomPainter {
  final List<DrawStroke> strokes;

  _DrawPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke;

      if (s.points.length > 1) {
        for (int i = 0; i < s.points.length - 1; i++) {
          if (s.points[i] != null && s.points[i + 1] != null) {
            canvas.drawLine(s.points[i], s.points[i + 1], paint);
          }
        }
      } else if (s.points.isNotEmpty) {
        canvas.drawPoints(PointMode.points, s.points, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
