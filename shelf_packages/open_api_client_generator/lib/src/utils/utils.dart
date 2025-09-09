Iterable<(I1, I2)> combine2<I1, I2>(Iterable<I1> items1, Iterable<I2> items2) sync* {
  final iterator1 = items1.iterator;
  final iterator2 = items2.iterator;

  while (iterator1.moveNext() && iterator2.moveNext()) {
    yield (iterator1.current, iterator2.current);
  }
}
