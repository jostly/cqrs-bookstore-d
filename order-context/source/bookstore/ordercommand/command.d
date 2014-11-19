module bookstore.ordercommand.command;

import bookstore.order.contract;
import bookstore.ordercommand.domain;

immutable struct PlaceOrderCommand {
	OrderId orderId;
	CustomerInformation customerInformation;
}