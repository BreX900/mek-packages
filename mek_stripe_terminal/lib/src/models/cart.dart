import 'package:mek_data_class/mek_data_class.dart';

part 'cart.g.dart';

@DataClass()
class Cart with _$Cart {
  final String currency;
  final int tax, total;
  final List<CartLineItem> lineItems;

  const Cart({
    required this.currency,
    required this.tax,
    required this.total,
    required this.lineItems,
  });
}

@DataClass()
class CartLineItem with _$CartLineItem {
  final String description;
  final int quantity;
  final int amount;

  const CartLineItem({
    required this.description,
    required this.quantity,
    required this.amount,
  });
}
