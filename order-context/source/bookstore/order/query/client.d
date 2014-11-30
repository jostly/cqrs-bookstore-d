module bookstore.order.query.client;

import std.typecons;
import vibe.d;

struct BookDto 
{
	string bookId;
	string isbn;
	string title;
	string description;
}

struct ProductDto 
{
	string productId;
	BookDto book;
	long price;
	string publisherContractId;
}

interface ProductAPI 
{
	// Underscore in variable name ties _productId it to the path parameter :productId
	@path("products/:productId") 
	Json getProduct(string _productId);
}

class ProductCatalogClient
{
	private ProductAPI client;
	
	this(string serviceUrl)
	{
		client = new RestInterfaceClient!ProductAPI(serviceUrl);
	}
	
	ProductDto getProduct(string productId)
	{
		auto json = client.getProduct(productId);
		if (json.type != Json.Type.null_) {
			return deserializeJson!ProductDto(json);
		}
		else return ProductDto();
	}
}


