module bookstore.order.command.resource;

import bookstore.order.command.command;
import bookstore.order.contract;
import bookstore.order.infrastructure;
import cqrslib.dispatcher;
import vibe.d;

interface OrderAPI {

	@path("")
	void placeOrder(string orderId, string customerName, string customerEmail, string customerAddress, CartDto cart);
	
}

struct CartDto {
	string cartId;
	long totalPrice;
	int totalQuantity;
	LineItemDto[] lineItems;
}

struct LineItemDto {
	string productId;
	string title;
	long price;
	int quantity;
	long totalPrice;
}

class OrderResource : OrderAPI {
	private Dispatcher commandBus;

	this(Dispatcher commandBus) {
		this.commandBus = commandBus;
	}

	void placeOrder(string orderId, string customerName, 
		string customerEmail, string customerAddress, CartDto cart) {

		OrderLine[] lines = cart.lineItems.map!(li => new OrderLine(new ProductId(li.productId), li.title, li.quantity, li.totalPrice)).array;

		auto command = new PlaceOrderCommand(
			new OrderId(orderId),
			new CustomerInformation(customerName, customerEmail, customerAddress), 
			lines, 
			cart.totalPrice
			);

		commandBus.dispatch(command);
	}
	
}


