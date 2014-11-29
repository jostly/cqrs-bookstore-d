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

	this(OrderId orderId, CustomerInformation customerInformation, OrderLine[] orderLines, long totalAmount) pure 
	{
		this.orderId = orderId;
		this.customerInformation = customerInformation;
		this.orderLines = orderLines;
		this.totalAmount = totalAmount;
	}

	this(inout OrderId orderId, inout CustomerInformation customerInformation, immutable(OrderLine)[] orderLines, long totalAmount) immutable pure 
	{
		this.orderId = new OrderId(orderId.id);
		this.customerInformation = customerInformation;
		this.orderLines = orderLines.idup;
		this.totalAmount = totalAmount;
	}

	override string toString() const
	{
		return classToString(this, orderId, customerInformation, orderLines, totalAmount);
	}
}

class ActivateOrderCommand
{
	OrderId orderId;
	
	this(OrderId orderId) pure
	{
		this.orderId = new OrderId(orderId.id);
	}
	
	override string toString() const
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