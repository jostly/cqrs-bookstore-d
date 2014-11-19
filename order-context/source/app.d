import std.conv, std.uuid, std.datetime, core.time;
import vibe.d;
import bookstore.ordercontext;

shared static this()
{
	auto time = Clock.currTime();

	auto t = new OrderPlacedEvent(
		OrderId.randomId(), 
		1, 
		time.toUnixTime() * 1000 + time.fracSec.msecs,
		new CustomerInformation("Hermerker Homolka", "hermerker@homolka.net", "Home Address")
	);
	logInfo("Your order is " ~ text(t));
	logInfo("Order in Json: " ~ text(t.toJson));
	logInfo("Reserialized from json: " ~ text(OrderPlacedEvent.fromJson(t.toJson)));

	auto api = new QueryResource;

	auto router = new URLRouter;
	router.registerRestInterface(api);

	auto routes = router.getAllRoutes();
    logInfo("routes: "~text(routes));

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);

	logInfo("order-context active on port " ~ text(settings.port));
}
