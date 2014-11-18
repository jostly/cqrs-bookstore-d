module bookstore.products.api;

import bookstore.products.domain;

struct BookDto {
	string bookId;
	string isbn;
	string title;
	string description;
}

struct ProductDto {
	string productId;
	BookDto book;
	long price;
	string publisherContractId;
}

// Allows product.toDto()
ProductDto toDto(Product product) {
	return ProductDto(
		product.productId, 
		product.book.toDto(),
		product.price,
		product.publisherContractId
		);
}

private BookDto toDto(Book book) {
	return BookDto(
		book.bookId,
		book.isbn,
		book.title,
		book.description
		);
}