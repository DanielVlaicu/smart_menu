import 'package:flutter/widgets.dart';

mixin AutoScrollOnDragMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();

  void autoScrollDuringDrag(PointerMoveEvent event) {
    const edgeMargin = 100.0;
    const scrollAmount = 12.0;

    final screenHeight = MediaQuery.of(context).size.height;
    final y = event.position.dy;

    if (y < edgeMargin) {
      final newOffset = (scrollController.offset - scrollAmount).clamp(
        0.0,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(newOffset);
    } else if (y > screenHeight - edgeMargin) {
      final newOffset = (scrollController.offset + scrollAmount).clamp(
        0.0,
        scrollController.position.maxScrollExtent,
      );
      scrollController.jumpTo(newOffset);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}