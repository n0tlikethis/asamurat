class Node<T> {
  Node({required this.value, this.next});
  T value;
  Node<T>? next;

  @override
  String toString() {
    if (next == null) return '$value';
    return '$value -> ${next.toString()}';
  }
}

class LinkedList<E> extends Iterable<E> {
  Node<E>? head;
  Node<E>? tail;

  @override
  bool get isEmpty => head == null;

  @override
  String toString() {
    if (isEmpty) return 'Empty list';
    return head.toString();
  }

  @override
  Iterator<E> get iterator => throw UnimplementedError();

  void push(E value) {
    head = Node(value: value, next: head);
    tail ??= head;
  }

  void append(E value) {
    // 1
    if (isEmpty) {
      push(value);
      return;
    }

    // 2
    tail!.next = Node(value: value);

    // 3
    tail = tail!.next;
  }

  Node<E>? nodeAt(int index) {
    // 1
    var currentNode = head;
    var currentIndex = 0;

    // 2
    while (currentNode != null && currentIndex < index) {
      currentNode = currentNode.next;
      currentIndex += 1;
    }
    return currentNode;
  }

  Node<E>? replaceAt(int index, E newValue) {
    var current = head;
    var currentIndex = 0;

    while (current != null && currentIndex < index) {
      current = current.next;
      currentIndex++;
    }

    if (current == null) return current;

    current.value = newValue;

    return current;
  }

  Node<E> insertAfter(Node<E> node, E value) {
    // 1
    if (tail == node) {
      append(value);
      return tail!;
    }

    // 2
    node.next = Node(value: value, next: node.next);
    return node.next!;
  }

  E? pop() {
    final value = head?.value;
    head = head?.next;
    if (isEmpty) {
      tail = null;
    }
    return value;
  }

  Node<E>? removeAt(int index) {
    var current = head;
    Node<E>? previous;
    var currentIndex = 0;

    while (current != null && currentIndex < index) {
      previous = current;
      current = current.next;
      currentIndex++;
    }

    if (current == null) return null;

    if (previous != null) {
      previous.next = current.next;
      if (current == tail) {
        tail = previous;
      }
    } else {
      head = current.next;
      if (head == null) {
        tail = null;
      }
    }

    return current;
  }

  E? removeLast() {
    // 1
    if (head?.next == null) return pop();

    // 2
    var current = head;
    while (current!.next != tail) {
      current = current.next;
    }

    // 3
    final value = tail?.value;
    tail = current;
    tail?.next = null;
    return value;
  }

  E? removeAfter(Node<E> node) {
    final value = node.next?.value;
    if (node.next == tail) {
      tail = node;
    }
    node.next = node.next?.next;
    return value;
  }

  @override
  List<E> toList({bool growable = true}) {
    var current = head;
    var resultList = <E>[];

    while (current != null) {
      resultList.add(current.value);
      current = current.next;
    }

    return resultList;
  }

  List<R> mapToList<R>(R Function(E) mapper) {
    var current = head;
    var resultList = <R>[];

    while (current != null) {
      resultList.add(mapper(current.value));
      current = current.next;
    }

    return resultList;
  }

  List<E> whereToList(bool Function(E) condition) {
    var current = head;
    var resultList = <E>[];

    while (current != null) {
      if (condition(current.value)) {
        resultList.add(current.value);
      }
      current = current.next;
    }

    return resultList;
  }

  @override
  int get length {
    var current = head;
    var count = 0;

    while (current != null) {
      count++;
      current = current.next;
    }

    return count;
  }
}
