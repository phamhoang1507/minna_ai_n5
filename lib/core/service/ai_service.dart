class AiService {
  Future<String> sendMessage(String userMessage) async {
    // TODO: gọi API AI
    // mock tạm
    await Future.delayed(const Duration(seconds: 1));

    return '''
いいですね！
あなたの日本語は自然です 👍
意味：Rất tốt! Câu tiếng Nhật của bạn khá tự nhiên.
''';
  }
}
