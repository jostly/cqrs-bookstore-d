module bookstore.order.contract;

import std.uuid;
import vibe.data.json;
import cqrslib.base;

class OrderId : GenericId 
{
	this(string id) pure 
	{
		super(id);
	}
	
	this() pure 
	{
		super("");
	}
	
	static OrderId randomId() 
	{
		return new OrderId(randomUUID().toString());
	}
}

unittest 
{
	auto id = "c5143565-ef1a-4084-a17b-59132edbb55a";
	// Should be possible to create both mutable and immutable OrderId
	auto a = new OrderId(id);
	auto b = new immutable OrderId(id);  
}

class ProductId : GenericId 
{

	this(string id) pure 
	{
		super(id);
	}

	this() pure 
	{
		super("");
	}	

	static ProductId randomId() 
	{
		return new ProductId(randomUUID().toString());
	}
}

unittest 
{
	auto id = "c5143565-ef1a-4084-a17b-59132edbb55a";
	// Should be possible to create both mutable and immutable ProductId
	auto a = new ProductId(id);
	auto b = new immutable ProductId(id);  
}

class PublisherContractId : GenericId
{
	this(string id) pure
	{
		super(id);
	}
	
	this() pure
	{
		super("");
	}
	
	static PublisherContractId randomId()
	{
		return new PublisherContractId(randomUUID().toString());
	}
}

struct CustomerInformation 
{
	string customerName;
	string email;
	string address;
}

struct OrderLine 
{
	ProductId productId;
	string title;
	int quantity;
	long unitPrice;
}

enum OrderStatus 
{ 
	NEW = "NEW", ACTIVATED = "ACTIVATED", PLACED = "PLACED" 
}
