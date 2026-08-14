package mek.stripeterminal

fun <K, V> Map<K, V>.toHashMap(): HashMap<K, V> {
    return hashMapOf(*map { (k, v) -> k to v }.toTypedArray())
}
