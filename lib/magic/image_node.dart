// ignore: file_names
import 'dart:ui' as ui show Image;
import 'dart:ui';

class ImageNode {
  late int curIndex;
  late int index;
  late Path path;
  late Rect rect;
  
  late ui.Image image;

  int getXIndex(int level) {
    return index % level;
  }

  int getYIndex(int level) {
    return (index / level).floor();
  }
}