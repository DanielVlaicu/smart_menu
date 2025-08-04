class ButtonDebouncer {
  bool _isRunning = false;

  Future<void> run(Future<void> Function() action) async {
    if (_isRunning) return;

    _isRunning = true;
    try {
      await action();
    } finally {
      _isRunning = false;
    }
  }
}