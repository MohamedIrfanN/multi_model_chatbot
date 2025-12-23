enum ChatModel {
  gpt4oMini,
  gpt4o,
  gpt41,
}

extension ChatModelX on ChatModel {
  String get label {
    switch (this) {
      case ChatModel.gpt4oMini:
        return 'GPT-4o mini';
      case ChatModel.gpt4o:
        return 'GPT-4o';
      case ChatModel.gpt41:
        return 'GPT-4.1';
    }
  }

  String get apiName {
    switch (this) {
      case ChatModel.gpt4oMini:
        return 'gpt-4o-mini';
      case ChatModel.gpt4o:
        return 'gpt-4o';
      case ChatModel.gpt41:
        return 'gpt-4.1';
    }
  }
}