import 'package:flutter/material.dart';
import 'package:jogo_2042/tile_model.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<TileModel>> grid = List.generate(
    4,
    (y) => List.generate(
      4,
      (x) => TileModel(x: x, y: y, value: 0),
    ),
  );

  List<TileModel> toAdd = [];

  Iterable<TileModel> get flattenedGrid => grid.expand((row) => row);
  Iterable<List<TileModel>> get cols => List.generate(4, (i) => List.generate(4, (j) => grid[j][i]));

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        for (var element in toAdd) {
          grid[element.y][element.x].value = element.value;
        }
        for (var element in flattenedGrid) {
          element.resetAnimation();
        }
        toAdd.clear();
      }
    });

    grid[1][2].value = 4;
    grid[0][2].value = 4;

    grid[3][2].value = 16;
    grid[0][0].value = 16;

    for (var element in flattenedGrid) {
      element.resetAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];
    stackItems.addAll(
      [flattenedGrid, toAdd].expand((e) => e).map(
            (e) => Positioned(
              left: e.animatedX.value * tileSize,
              top: e.animatedY.value * tileSize,
              width: tileSize,
              height: tileSize,
              child: Center(
                child: Container(
                  width: (tileSize - 4.0 * 2) * e.scaleAnimation.value,
                  height: (tileSize - 4.0 * 2) * e.scaleAnimation.value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: lightBrown,
                  ),
                ),
              ),
            ),
          ),
    );

    stackItems.addAll(
      flattenedGrid.map(
        (e) => AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return e.animationValue.value == 0
                  ? const SizedBox()
                  : Positioned(
                      left: e.x * tileSize,
                      top: e.y * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Center(
                        child: Container(
                            width: tileSize - 4.0 * 2,
                            height: tileSize - 4.0 * 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: numTileColor[e.animationValue.value],
                            ),
                            child: Center(
                              child: Text(
                                e.animationValue.value.toString(),
                                style: TextStyle(
                                  color: e.animationValue.value <= 4 ? greyText : Colors.white,
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            )),
                      ),
                    );
            }),
      ),
    );

    return Scaffold(
      backgroundColor: tan,
      body: Center(
        child: Container(
          width: gridSize,
          height: gridSize,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: darkBrown,
          ),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy < -250 && canSwipeUp()) {
                // joga pra cima
                doSwipe(swipeUp);
              } else if (details.velocity.pixelsPerSecond.dy > 250 && canSwipeDown()) {
                // joga pra baixo
                doSwipe(swipeDown);
              }
            },
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx < -1000 && canSwipeLeft()) {
                // joga pra esquerda
                doSwipe(swipeLeft);
              } else if (details.velocity.pixelsPerSecond.dx > 1000 && canSwipeRight()) {
                // joga pra direita
                doSwipe(swipeRight);
              }
            },
            child: Stack(
              children: stackItems,
            ),
          ),
        ),
      ),
    );
  }

  void addNewTile() {
    List<TileModel> emptySpots = flattenedGrid.where((element) => element.value == 0).toList();

    emptySpots.shuffle();

    if (emptySpots.isNotEmpty) {
      TileModel tile = emptySpots.first;
      tile.value = 2;
      tile.appear(controller);
      toAdd.add(tile);
    }
  }

  void doSwipe(void Function() swipeDirection) {
    setState(() {
      swipeDirection();
      addNewTile();
      controller.forward(from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => cols.any(canSwipe);
  bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<TileModel> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].value == 0) {
        if (tiles.skip(i + 1).any((e) => e.value > 0)) return true;
      } else {
        TileModel tileNaoVazio = tiles.skip(i + 1).firstWhere((element) => element.value > 0, orElse: () => tiles.last);

        if (tileNaoVazio.value != null && tileNaoVazio.value == tiles[i].value) return true;
      }
    }
    return false;
  }

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
  void swipeUp() => cols.forEach(mergeTiles);
  void swipeDown() => cols.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<TileModel> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Iterable<TileModel> toCheck = tiles.skip(i).skipWhile((value) => value.value == 0);

      if (toCheck.isNotEmpty) {
        TileModel t = toCheck.first;
        TileModel? merge = toCheck.skip(1).firstWhere((element) => element.value != 0, orElse: () => t);

        if (merge != null && merge.value != t.value) {
          merge = null;
        }
        if (tiles[i] != t || merge != null) {
          int resultValue = t.value;
          t.moveTo(controller, tiles[i].x, tiles[i].y);
          // animar posição de T
          if (merge != null) {
            resultValue += merge.value;

            merge.moveTo(controller, tiles[i].x, tiles[i].y);
            merge.bounce(controller);
            merge.changeNumber(controller, resultValue);

            merge.value = 0;

            t.changeNumber(controller, 0);
            // animar posição de merge
          }
          t.value = 0;
          tiles[i].value = resultValue;
        }
      }
    }
  }
}

const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
const Color tan = Color.fromARGB(255, 238, 228, 218);
const Color greyText = Color.fromARGB(255, 119, 110, 101);

const Map<int, Color> numTileColor = {
  2: tan,
  4: tan,
  8: Color.fromARGB(255, 242, 177, 121),
  16: Color.fromARGB(255, 245, 149, 99),
  32: Color.fromARGB(255, 246, 124, 95),
  64: Color.fromARGB(255, 246, 94, 59),
  128: Color.fromARGB(255, 237, 207, 114),
  256: Color.fromARGB(255, 237, 204, 97),
  512: Color.fromARGB(255, 237, 200, 80),
  1024: Color.fromARGB(255, 237, 197, 63),
  2048: Color.fromARGB(255, 237, 194, 46),
};
