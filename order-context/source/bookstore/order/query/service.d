module bookstore.order.query.service;

import bookstore.order.query.orderlist;
import bookstore.order.query.client;

class QueryService 
{
	private OrderListDenormalizer orderListDenormalizer;
	private ProductCatalogClient productCatalogClient;
	
	this(OrderListDenormalizer orderListDenormalizer, ProductCatalogClient productCatalogClient) 
	{
		this.orderListDenormalizer = orderListDenormalizer;
		this.productCatalogClient = productCatalogClient;
	}
	
	OrderProjection[] getOrders() 
	{
		return orderListDenormalizer.getOrders();
	}
	
	PublisherContractId findPublisherContract(const ProductId productId)
	{
		auto product = productCatalogClient.getProduct(productId.id);
		return new PublisherContractId(product.publisherContractId);
	}
	
}