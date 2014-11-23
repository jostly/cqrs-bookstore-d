module bookstore.ordercommand.command;

import bookstore.order.contract;
import bookstore.order.infrastructure;
import bookstore.ordercommand.domain;
import cqrslib.command;
import cqrslib.base;

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
	private Repository!(OrderId, Order) repository;
	
	this(Repository!(OrderId, Order) repository) {
		this.repository = repository;
	}

	void register(SyncCommandBus commandBus) {
		commandBus.register(&handlePlaceOrderCommand);
	}

	void handlePlaceOrderCommand(PlaceOrderCommand command) {
		auto order = new Order;
		order.place(command.orderId, command.customerInformation, command.orderLines, command.totalAmount);
		repository.save(order);
	}

}