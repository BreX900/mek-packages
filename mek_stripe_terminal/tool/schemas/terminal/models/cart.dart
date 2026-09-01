/// An [CartApi] object contains information about what line items are included in the current transaction.
/// A cart object should be created and then passed into [StripeTerminal.setReaderDisplay], which
/// will display the cart’s contents on the reader’s screen.
///
/// The [CartApi] only represents exactly what will be shown on the screen, and is not reflective
/// of what the customer is actually charged. You are responsible for making sure that tax
/// and total reflect what is in the cart.
///
/// These values are exactly what will be shown on the screen and do not reflect what the user is actually charged.
///
/// Note: Only Internet readers support setReaderDisplay functionality
class CartApi {
  /// The currency of the cart.
  final String currency;

  /// The displayed tax amount, provided in the currency’s smallest unit.
  final int tax;

  /// The cart’s total balance, provided in the currency’s smallest unit.
  final int total;

  /// The cart’s line items. Default’s to an empty array of line items.
  final List<CartLineItemApi> lineItems;

  const CartApi({
    required this.currency,
    this.tax = 0,
    required this.total,
    required this.lineItems,
  });
}

/// Represents a single line item in an [CartApi], displayed on the reader’s screen during checkout.
///
/// The values here will be shown on the screen as-is. Make sure you’re correctly calculating
/// and setting the [CartApi]‘s tax and total – the reader will not calculate tax or total for you.
/// Similarly, make sure the values displayed reflect what the customer is actually charged.
class CartLineItemApi {
  /// The description or name of the item.
  final String descriptionX;

  /// The quantity of the line item being purchased.
  final int quantity;

  /// The price of the item, provided in the cart’s currency’s smallest unit. The line item will
  /// assume the currency of the parent [CartApi].
  final int amount;

  const CartLineItemApi({required this.descriptionX, required this.quantity, required this.amount});
}
