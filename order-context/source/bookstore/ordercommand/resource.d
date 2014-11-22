module bookstore.ordercommand.resource;

import bookstore.ordercommand.command;
import bookstore.order.contract;
import bookstore.order.infrastructure;
import cqrslib.command;
import vibe.d;

interface OrderAPI {

	@path("")
	void placeOrder(string orderId, string customerName, string customerEmail, string customerAddress, CartDto cart);
	
	@path("v2")
	void placeOrder2(Json _dummy);

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
	private SyncCommandBus commandBus;

	this(SyncCommandBus commandBus) {
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
	
	void placeOrder2(Json json) {
		import std.conv;
		logInfo("Received: "~text(json));
	}
		

}


