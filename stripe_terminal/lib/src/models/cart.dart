import 'package:mek_data_class/mek_data_class.dart';

part 'cart.g.dart';

/// An [Cart] object contains information about what line items are included in the current transaction.
/// A cart object should be created and then passed into [StripeTerminal.setReaderDisplay], which
/// will display the cart’s contents on the reader’s screen.
///
/// The [Cart] only represents exactly what will be shown on the screen, and is not reflective
/// of what the customer is actually charged. You are responsible for making sure that tax
/// and total reflect what is in the cart.
///
/// These values are exactly what will be shown on the screen and do not reflect what the user is actually charged.
///
/// Note: Only Internet readers support setReaderDisplay functionality
@DataClass()
class Cart with _$Cart {
  /// The currency of the cart.
  final String currency;

  /// The displayed tax amount, provided in the currency’s smallest unit.
  final int tax;

  /// The cart’s total balance, provided in the currency’s smallest unit.
  final int total;

  /// The cart’s line items. Default’s to an empty array of line items.
  final List<CartLineItem> lineItems;

  const Cart({
    required this.currency,
    this.tax = 0,
    required this.total,
    required this.lineItems,
  });
}

/// Represents a single line item in an [Cart], displayed on the reader’s screen during checkout.
///
/// The values here will be shown on the screen as-is. Make sure you’re correctly calculating
/// and setting the [Cart]‘s tax and total – the reader will not calculate tax or total for you.
/// Similarly, make sure the values displayed reflect what the customer is actually charged.
@DataClass()
class CartLineItem with _$CartLineItem {
  /// The description or name of the item.
  final String description;

  /// The quantity of the line item being purchased.
  final int quantity;

  /// The price of the item, provided in the cart’s currency’s smallest unit. The line item will
  /// assume the currency of the parent [Cart].
  final int amount;

  const CartLineItem({
    required this.description,
    required this.quantity,
    required this.amount,
  });
}
