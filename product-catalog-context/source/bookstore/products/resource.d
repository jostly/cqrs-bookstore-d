module bookstore.products.resource;

import std.typecons, std.algorithm, std.array;
import vibe.web.rest;

import bookstore.products.domain;
import bookstore.products.api;
import bookstore.products.infrastructure;

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
		/*
		repository.save(Product("elven", Book("foo", "bar", "baz", "brr"), 12345, "nope"));
		repository.save(Product("twelven", Book("a", "b", "c", "d"), 9999, "yep"));
		*/
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