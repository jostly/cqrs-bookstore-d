module bookstore.order.command.command;

import bookstore.order.contract;
import bookstore.order.command.domain;
import cqrslib.bus;
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

class ActivateOrderCommand
{
	OrderId orderId;
	
	this(OrderId orderId)
	{
		this.orderId = orderId;
	}
	
	override string toString()
	{
		return classToString(this, orderId);
	}
}

class OrderCommandHandler {
	private Repository repository;
	
	this(Repository repository) {
		this.repository = repository;
	}

	@subscribe void handlePlaceOrderCommand(PlaceOrderCommand command) {
		auto order = new Order;
		order.place(command.orderId, command.customerInformation, command.orderLines, command.totalAmount);
		repository.save(order);
	}
	
	@subscribe void handleActivate(ActivateOrderCommand command)
	{
		auto order = repository.load!(Order, OrderId)(command.orderId);
		order.activate();
		repository.save(order);
	}
}