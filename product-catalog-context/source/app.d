import vibe.d;
import bookstore.domain;
import bookstore.infrastructure;
import bookstore.api;
import std.conv, std.algorithm, std.typecons, std.array, std.stdio;
//import vibe.data.json;
//import vibe.http.common;

interface ProductAPI {
	ProductDto[] getProducts();

	// Underscore in variable name ties _productId it to the path parameter :productId
	@path("/product/:productId") 
	Nullable!ProductDto getProduct(string _productId);

	// Would be great if I could just accept a ProductDto here, but it doesn't
	// seem possible. TODO: ask on forum
	void createProduct(string productId, BookDto book, long price, string publisherContractId);
}

class ProductAPIImpl : ProductAPI {
	private ProductRepository repository = new InMemoryProductRepository();

	this() {
		repository.save(Product("elven", Book("foo", "bar", "baz", "brr"), 12345, "nope"));
		repository.save(Product("twelven", Book("a", "b", "c", "d"), 9999, "yep"));
	}

	override ProductDto[] getProducts() { 
		return repository.getProducts().map!(a => toDto(a)).array;
	}

	override Nullable!ProductDto getProduct(string productId) {
		auto p = repository.getProduct(productId);
		if (p.isNull()) {
			// throw new HttpStatusException(404);
			return Nullable!ProductDto();
		} else {
			return Nullable!ProductDto(toDto(p));
		}
	}

	override void createProduct(string productId, BookDto book, long price, string publisherContractId) {
		auto _book = Book(book.bookId, book.isbn, book.title, book.description);
		auto _product = Product(productId, _book, price, publisherContractId);
		repository.save(_product);
	}
}

shared static this()
{
	auto api = new ProductAPIImpl;


	auto router = new URLRouter;
	router.registerRestInterface(api);

	auto routes = router.getAllRoutes();
	logInfo("routes: "~text(routes));

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");

}
