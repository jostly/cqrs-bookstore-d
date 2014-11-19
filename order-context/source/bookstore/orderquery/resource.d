module bookstore.orderquery.resource;

interface QueryAPI {
	string getOrders();
}

class QueryResource : QueryAPI {
	override string getOrders() {
		return "this is a placeholder";
	}
}