module bookstore.order.contract;

import cqrslib.base : GenericId;

class OrderId : GenericId {

	this(string id) {
		super(id);
	}

	static auto randomId() {
		return new OrderId(randomUUID().toString());
	}

}