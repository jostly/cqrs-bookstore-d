module bookstore.order.query.orderlist;

public import bookstore.order.contract;
import bookstore.order.event;
import cqrslib.bus : subscribe;
import cqrslib.event : DomainEventListener;

interface OrderProjectionRepository 
{
	void save(OrderProjection orderProjection);

	OrderProjection getById(const OrderId orderId);

	OrderProjection[] listOrdersByTimestamp();
}

struct OrderLineProjection 
{
	ProductId productId;
	string title;
	int quantity;
	long unitPrice;
}

private OrderLineProjection[] lineProjection(const(OrderLine)[] lines)
{
	OrderLineProjection[] result;
	foreach (line; lines)
	{
		result ~= OrderLineProjection(new ProductId(line.productId.id), line.title, line.quantity, line.unitPrice);
	}
	return result;
}

struct OrderProjection 
{
	OrderId orderId;
	long orderPlacedTimestamp;
	long orderAmount;
	string customerName;
	OrderLineProjection[] orderLines;
	OrderStatus status;
}

class OrderListDenormalizer : DomainEventListener 
{
	private OrderProjectionRepository repository;
	
	this(OrderProjectionRepository repository) 
	{
		this.repository = repository;
	}
		
	@subscribe void handleOrderPlacedEvent(immutable OrderPlacedEvent event) 
	{
		repository.save(OrderProjection(new OrderId(event.aggregateId.id), event.timestamp, event.orderAmount, event.customerInformation.customerName,
				lineProjection(event.orderLines), OrderStatus.PLACED));
	}
	
	@subscribe void handleOrderActivatedEvent(immutable OrderActivatedEvent event) 
	{
		OrderProjection projection = repository.getById(event.aggregateId);
		projection.status = OrderStatus.ACTIVATED;
		repository.save(projection);
	}	
	
	OrderProjection[] getOrders() 
	{
		return repository.listOrdersByTimestamp();
	}
	
	bool supportsReplay() 
	{ 
		return true; 
	}
}
