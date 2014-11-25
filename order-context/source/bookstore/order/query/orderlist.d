module bookstore.order.query.orderlist;

public import bookstore.order.contract;
import bookstore.order.event : OrderPlacedEvent;
import cqrslib.bus : subscribe;
import cqrslib.event : DomainEventListener;

interface OrderProjectionRepository {

	void save(OrderProjection orderProjection);

	OrderProjection getById(OrderId orderId);

	OrderProjection[] listOrdersByTimestamp();
}

struct OrderLineProjection {
	ProductId productId;
	string title;
	int quantity;
	long unitPrice;
}

private OrderLineProjection[] lineProjection(OrderLine[] lines)
{
	OrderLineProjection[] result;
	foreach (line; lines)
	{
		result ~= OrderLineProjection(line.productId, line.title, line.quantity, line.unitPrice);
	}
	return result;
}

struct OrderProjection {
	OrderId orderId;
	long orderPlacedTimestamp;
	long orderAmount;
	string customerName;
	OrderLineProjection[] orderLines;
	OrderStatus status;
}

class OrderListDenormalizer : DomainEventListener {
	private OrderProjectionRepository repository;
	
	this(OrderProjectionRepository repository) {
		this.repository = repository;
	}
		
	@subscribe void handleOrderPlacedEvent(OrderPlacedEvent event) {
		repository.save(OrderProjection(event.aggregateId, event.timestamp, event.orderAmount, event.customerInformation.customerName,
				lineProjection(event.orderLines), OrderStatus.PLACED));
	}	
	
	OrderProjection[] getOrders() {
		return repository.listOrdersByTimestamp();
	}
	
	bool supportsReplay() { return true; }
}