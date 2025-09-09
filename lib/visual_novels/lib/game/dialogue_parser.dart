import 'dart:async';

class DialogueParser {
  // Dialogue nodes parsed from files
  final Map<String, DialogueNode> nodes = {};

  // Current state variables
  final Map<String, dynamic> variables = {};

  DialogueParser();

  // Parse dialogue content (Yarn format)
  void parseContent(String content) {
    DialogueNode? currentNode;
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check for node title
      if (line.startsWith('title:')) {
        final nodeTitle = line.substring(6).trim();
        currentNode = DialogueNode(nodeTitle);
        nodes[nodeTitle] = currentNode;
        continue;
      }

      // Check for node end
      if (line == '===') {
        currentNode = null;
        continue;
      }

      // Skip empty lines
      if (line.isEmpty) {
        continue;
      }

      // Add content to current node
      if (currentNode != null) {
        // Check for commands
        if (line.startsWith('<<')) {
          // Command line
          final commandContent = line.substring(2, line.length - 2).trim();
          currentNode.content.add(DialogueLine(
            type: DialogueLineType.command,
            content: commandContent,
          ));
        } else if (line.startsWith('#')) {
          // Comment/tag line
          currentNode.content.add(DialogueLine(
            type: DialogueLineType.tag,
            content: line,
          ));
        } else if (line.contains('->')) {
          // Jump line
          currentNode.content.add(DialogueLine(
            type: DialogueLineType.jump,
            content: line,
          ));
        } else if (line.contains('[') && line.contains(']')) {
          // Choice line
          currentNode.content.add(DialogueLine(
            type: DialogueLineType.choice,
            content: line,
          ));
        } else {
          // Regular dialogue line
          currentNode.content.add(DialogueLine(
            type: DialogueLineType.dialogue,
            content: line,
          ));
        }
      }
    }
  }

  // Get a node by title
  DialogueNode? getNode(String title) {
    return nodes[title];
  }

  // Process command line and extract command name and arguments
  DialogueCommand parseCommand(String commandLine) {
    // Split the command by spaces but preserve quoted strings
    final parts = _splitCommandLine(commandLine);

    if (parts.isEmpty) {
      return DialogueCommand('', []);
    }

    final commandName = parts[0];
    final arguments = parts.length > 1 ? parts.sublist(1) : <String>[];

    return DialogueCommand(commandName, arguments);
  }

  // Process variable declarations and assignments
  void processVariables(String commandLine) {
    if (commandLine.startsWith('declare')) {
      // Variable declaration
      final parts = _splitCommandLine(commandLine);
      if (parts.length >= 3 && parts[1].startsWith('\$')) {
        final variableName = parts[1].substring(1);
        final value = _parseValue(parts[2]);
        variables[variableName] = value;
      }
    } else if (commandLine.startsWith('set')) {
      // Variable assignment
      final parts = _splitCommandLine(commandLine);
      if (parts.length >= 3 && parts[1].startsWith('\$')) {
        final variableName = parts[1].substring(1);
        final value = _parseValue(parts[2]);
        variables[variableName] = value;
      }
    }
  }

  // Helper method to parse a value from string to appropriate type
  dynamic _parseValue(String valueStr) {
    // Try to parse as boolean
    if (valueStr.toLowerCase() == 'true') return true;
    if (valueStr.toLowerCase() == 'false') return false;

    // Try to parse as number
    final numValue = double.tryParse(valueStr);
    if (numValue != null) {
      // If it's a whole number, return as int
      if (numValue == numValue.roundToDouble()) {
        return numValue.toInt();
      }
      return numValue;
    }

    // Return as string (remove quotes if present)
    if (valueStr.startsWith('"') && valueStr.endsWith('"')) {
      return valueStr.substring(1, valueStr.length - 1);
    }

    return valueStr;
  }

  // Helper method to split command line preserving quoted strings
  List<String> _splitCommandLine(String line) {
    List<String> result = [];
    bool inQuotes = false;
    String current = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
        current += char;
      } else if (char == ' ' && !inQuotes) {
        if (current.isNotEmpty) {
          result.add(current);
          current = '';
        }
      } else {
        current += char;
      }
    }

    if (current.isNotEmpty) {
      result.add(current);
    }

    return result;
  }

  // Parse choices from a choice line
  List<DialogueChoice> parseChoices(String choiceLine) {
    final List<DialogueChoice> choices = [];

    // Extract choices in [brackets]
    final RegExp choiceRegex = RegExp(r'\[(.*?)\]');
    final matches = choiceRegex.allMatches(choiceLine);

    for (final match in matches) {
      final choiceText = match.group(1)?.trim() ?? '';
      if (choiceText.isNotEmpty) {
        choices.add(DialogueChoice(choiceText, ''));
      }
    }

    return choices;
  }

  // Check condition and return whether it's true
  bool evaluateCondition(String condition) {
    // Simple condition evaluation for demo
    if (condition.contains('==')) {
      final parts = condition.split('==').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final left = _resolveVariableOrValue(parts[0]);
        final right = _resolveVariableOrValue(parts[1]);
        return left == right;
      }
    } else if (condition.contains('!=')) {
      final parts = condition.split('!=').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final left = _resolveVariableOrValue(parts[0]);
        final right = _resolveVariableOrValue(parts[1]);
        return left != right;
      }
    } else if (condition.contains('>')) {
      final parts = condition.split('>').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final left = _resolveVariableOrValue(parts[0]);
        final right = _resolveVariableOrValue(parts[1]);
        if (left is num && right is num) {
          return left > right;
        }
      }
    } else if (condition.contains('<')) {
      final parts = condition.split('<').map((p) => p.trim()).toList();
      if (parts.length == 2) {
        final left = _resolveVariableOrValue(parts[0]);
        final right = _resolveVariableOrValue(parts[1]);
        if (left is num && right is num) {
          return left < right;
        }
      }
    } else if (condition.startsWith('\$')) {
      // Check if variable exists and is true
      final varName = condition.substring(1);
      return variables.containsKey(varName) &&
          (variables[varName] == true || variables[varName] == 1);
    }

    return false;
  }

  // Resolve a variable or literal value
  dynamic _resolveVariableOrValue(String str) {
    if (str.startsWith('\$')) {
      // It's a variable
      final varName = str.substring(1);
      return variables[varName];
    } else {
      // Try to parse as a value
      return _parseValue(str);
    }
  }
}

// Classes to represent dialogue structure
class DialogueNode {
  final String title;
  final List<DialogueLine> content = [];

  DialogueNode(this.title);
}

enum DialogueLineType {
  dialogue,
  command,
  jump,
  choice,
  tag,
}

class DialogueLine {
  final DialogueLineType type;
  final String content;

  DialogueLine({
    required this.type,
    required this.content,
  });

  @override
  String toString() {
    return 'DialogueLine(type: $type, content: $content)';
  }
}

class DialogueCommand {
  final String name;
  final List<String> arguments;

  DialogueCommand(this.name, this.arguments);

  @override
  String toString() {
    return 'DialogueCommand(name: $name, arguments: $arguments)';
  }
}

class DialogueChoice {
  final String text;
  final String destination;

  DialogueChoice(this.text, this.destination);
}