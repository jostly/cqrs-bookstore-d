module bookstore.order.command.resource;

import bookstore.order.command.command;
import bookstore.order.contract;
import bookstore.order.infrastructure;
import cqrslib.bus;
import vibe.d;

interface OrderAPI {

	@path("")
	void placeOrder(string orderId, string customerName, string customerEmail, string customerAddress, CartDto cart);
	
	@path("activations")
	void activateOrder(string orderId);
	
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
	private Bus commandBus;

	this(Bus commandBus) {
		this.commandBus = commandBus;
	}

	void placeOrder(string orderId, string customerName, 
		string customerEmail, string customerAddress, CartDto cart) {

		immutable(OrderLine)[] lines = cart.lineItems.map!(li => immutable OrderLine(new ProductId(li.productId), li.title, li.quantity, li.totalPrice)).array;

		auto command = new immutable PlaceOrderCommand(
			new OrderId(orderId),
			immutable CustomerInformation(customerName, customerEmail, customerAddress), 
			lines, 
			cart.totalPrice
			);
		commandBus.dispatch(command);
	}
	
	void activateOrder(string orderId) 
	{
		auto command = new immutable ActivateOrderCommand(new OrderId(orderId));
		commandBus.dispatch(command);
	}
	
}


