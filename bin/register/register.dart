abstract class Register<K, V> {
  operator []=(K key, V v);
  V operator [](K key);

  V PC();
}
