enum ChatMode {
  chat,
  grammar,
  vocabulary;

  String get displayName {
    switch (this) {
      case ChatMode.chat:
        return 'Chat';
      case ChatMode.grammar:
        return 'Grammar';
      case ChatMode.vocabulary:
        return 'Vocabulary';
    }
  }

  String get welcomeTitle {
    switch (this) {
      case ChatMode.chat:
        return 'Welcome to LinguaNova Assistant';
      case ChatMode.grammar:
        return 'Grammar Check Mode';
      case ChatMode.vocabulary:
        return 'Vocabulary Explorer';
    }
  }

  String get welcomeMessage {
    switch (this) {
      case ChatMode.chat:
        return 'I\'m your language learning assistant. Ask me anything and I\'ll help you improve your English skills!';
      case ChatMode.grammar:
        return 'Send me any text and I\'ll check it for grammar mistakes, providing corrections and explanations.';
      case ChatMode.vocabulary:
        return 'Type any word and I\'ll explain its meaning, usage, and provide helpful examples.';
    }
  }

  String get endpoint {
    switch (this) {
      case ChatMode.chat:
        return 'chat';
      case ChatMode.grammar:
        return 'grammar';
      case ChatMode.vocabulary:
        return 'vocabulary';
    }
  }
}