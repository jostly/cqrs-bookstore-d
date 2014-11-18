import std.conv;
import vibe.d;
import bookstore.products.domain;
import bookstore.products.infrastructure;
import bookstore.products.api;
import bookstore.products.resource;

shared static this()
{
	auto api = new ProductAPIImpl;

	auto router = new URLRouter;
	router.registerRestInterface(api);

	auto routes = router.getAllRoutes();

	auto settings = new HTTPServerSettings;
	settings.port = 8090;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);

	logInfo("product-catalog-context active on port " ~ text(settings.port));

}
