module bookstore.order.command.command;

import bookstore.order.contract;
import bookstore.order.command.domain;
import cqrslib.dispatcher;
import cqrslib.base;
import cqrslib.domain;

class PlaceOrderCommand {
	OrderId orderId;
	CustomerInformation customerInformation;
	OrderLine[] orderLines;
	long totalAmount;

	this(OrderId orderId, CustomerInformation customerInformation, OrderLine[] orderLines, long totalAmount) {
		this.orderId = orderId;
		this.customerInformation = customerInformation;
		this.orderLines = orderLines;
		this.totalAmount = totalAmount;
	}

	override string toString() {
		return classToString(this, orderId, customerInformation, orderLines, totalAmount);
	}
}

class OrderCommandHandler {
	private Repository repository;
	
	this(Repository repository) {
		this.repository = repository;
	}

	void handlePlaceOrderCommand(PlaceOrderCommand command) {
		auto order = new Order;
		order.place(command.orderId, command.customerInformation, command.orderLines, command.totalAmount);
		repository.save(order);
	}
}