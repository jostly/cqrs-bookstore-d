module bookstore.domain;

import cqrslib.domain;
import std.typecons;
import specd.specd;
/* 
immutable struct as value object because:

- it has value semantics by being a struct
- builtin equality by comparing fields
- builtin toString by outputting name and fields (using std.conv)
- copy on assignment
- cannot change fields after creation

*/
immutable struct Book {
	string bookId;
	string isbn;
	string title;
	string description;
}

immutable struct Product {
	string productId;
	Book book;
	long price;
	string publisherContractId;
}

unittest {
	auto book1 = Book("a", "b", "c", "d");
	auto prod1 = Product("e", book1, 12345, "f");

	auto book2 = Book("1", "2", "3", "4");
	auto prod2 = Product("5", book2, -1, "6");

	auto book3 = Book("a", "b", "c", "d");
	auto prod3 = Product("e", book3, 12345, "f");

	//assertNotEqual(book1, book2);
	//assertEqual(book1, book3);
	//assertNotEqual(prod1, prod2);
	//assertEqual(prod1, prod3);
	//assertNotEqual(prod3, prod4);

	describe("books")
		.should("be equal if all terms are equal", book1.must.be.equal(book3))
		.should("not be equal if a term differs", book1.must.not.be.equal(book2))
		;

	describe("products")
		.should("be equal if all terms are equal", prod1.must.be.equal(prod3))
		.should("not be equal if a term differs", prod1.must.not.be.equal(prod2))
		;

}

// TODO: Nullable!Product may be the right type, but I would be more comfortable
// with an Option type like in Scala, since I think it expresses intent better

interface ProductRepository {
	Product[] getProducts();
	Nullable!Product getProduct(string productId);
	void save(Product product);
}
