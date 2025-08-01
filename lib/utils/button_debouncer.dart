class ButtonDebouncer {
  bool _isProcessing = false;

  Future<void> run(Future<void> Function() action) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      await action();
    } finally {
      _isProcessing = false;
    }
  }
}