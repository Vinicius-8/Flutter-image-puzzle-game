import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imazzler/magic/image_node.dart';
import 'package:image/image.dart' as img;

class PuzzleMagic {
  late ui.Image image;
  late double eachWidth;
  late Size screenSize;
  late double baseX;
  late double baseY;

  late int level;
  late double eachBitmapWidth;

  Future<ui.Image> init(String path, Size size, int level, bool isCustomImagePath) async {
    if(isCustomImagePath){
      image = await getImageFromFile(path);
    } else {
      await getImage(path);
    }

    screenSize = size;
    this.level = level;
    eachWidth = screenSize.width * 0.8 / level;
    baseX = screenSize.width * 0.1;
    baseY = (screenSize.height - screenSize.width) * 0.5;

    eachBitmapWidth = (image.width / level);
    return image;
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  // Future<ui.Image> getImageFromFile(String path) async {
  //   final ByteData data = ByteData.sublistView(await File(path).readAsBytes());
  //   image = await decodeImageFromList(data.buffer.asUint8List());
  //   return image;
  // }



  Future<ui.Image> loadImage(Uint8List imgBytes) async {
    final codec = await ui.instantiateImageCodec(imgBytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Uint8List resizeImage(Uint8List data, int width, int height) {
    // Decode the image from bytes
    img.Image? image = img.decodeImage(data);
    if (image == null) {
      throw Exception("Failed to decode image.");
    }

    // Resize the image to the desired size
    img.Image resizedImage = img.copyResize(image, width: width, height: height);

    // Convert the resized image to Uint8List
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<ui.Image> getImageFromFile(String path) async {
    final File file = File(path);
    final Uint8List bytes = await file.readAsBytes();

    // Redimensione a imagem para o tamanho desejado (e.g., 500x500)
    int desiredSize = 500;
    Uint8List resizedBytes = resizeImage(bytes, desiredSize, desiredSize);

    // Use a função instantiateImageCodec para carregar a imagem redimensionada como ui.Image
    final codec = await ui.instantiateImageCodec(resizedBytes);
    final frame = await codec.getNextFrame();    
    return frame.image;
  }



Future<List<ImageNode>> generatePuzzlePieces() async {
    // Cria uma lista vazia para armazenar as peças do quebra-cabeça
    List<ImageNode> list = [];

    // Loop para percorrer as linhas da grade do quebra-cabeça
    for (int j = 0; j < level; j++) {
      // Loop para percorrer as colunas da grade do quebra-cabeça
      for (int i = 0; i < level; i++) {
        // Verifica se a posição atual não é a última (deixa uma posição vazia no quebra-cabeça)
        if (j * level + i < level * level - 1) {
          // Cria uma nova instância de ImageNode para a peça do quebra-cabeça
          ImageNode node = ImageNode();

          // Define a posição correta do retângulo da peça na grade
          node.rect = getOkRectF(i, j);

          // Define o índice da peça baseado em sua posição na grade
          node.index = j * level + i;

          // Gera a imagem correspondente à peça do quebra-cabeça
          node = await makeBitmap(node);
           

          // Adiciona a peça configurada à lista de peças
          //node.image = Image(image: ) as ui.Image;
          list.add(node);          
        }
      }
    }

    // Retorna a lista completa de peças do quebra-cabeça
    return list;
  }


  Rect getOkRectF(int i, int j) {
    return Rect.fromLTWH(
        baseX + eachWidth * i, baseY + eachWidth * j, eachWidth, eachWidth);
  }

  Future<ImageNode> makeBitmap(ImageNode node) async {
    int i = node.getXIndex(level);
    int j = node.getYIndex(level);

    Rect rect = getShapeRect(i, j, eachBitmapWidth);
    rect = rect.shift(
        Offset(eachBitmapWidth.toDouble() * i, eachBitmapWidth.toDouble() * j));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachBitmapWidth.toDouble();
    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0.0, 0.0, ww, ww));

    Rect rect2 = Rect.fromLTRB(0.0, 0.0, rect.width, rect.height);

    Paint paint = Paint();
    canvas.drawImageRect(image, rect, rect2, paint);
    // recorder.endRecording().toImage(ww.floor(), ww.floor()).then((value) {
    //   node.image = value;  
    // },);
    node.image = await recorder.endRecording().toImage(ww.floor(), ww.floor());
    node.rect = getOkRectF(i, j);
    return node;
  }

  Rect getShapeRect(int i, int j, double width) {
    return Rect.fromLTRB(0.0, 0.0, width, width);
  }
}
