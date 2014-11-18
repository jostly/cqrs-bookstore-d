module bookstore.infrastructure;

import bookstore.domain;
import std.typecons;

class InMemoryProductRepository : ProductRepository {

	private Product[string] _products;

	override Product[] getProducts() {
		return _products.values;
	}

	override Nullable!Product getProduct(string productId) {
		auto product = productId in _products;
		if (product != null) {
			return Nullable!Product(*product);
		} else {
			return Nullable!Product();
		}
	}

	override void save(Product product) {
		_products[product.productId] = product;
	}

}

unittest {
}