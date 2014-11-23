import std.conv;
import vibe.d;
import bookstore.products.domain;
import bookstore.products.infrastructure;
import bookstore.products.api;
import bookstore.products.resource;

void accessFilter(HTTPServerRequest req, HTTPServerResponse res)
{
	/*
	res.headers["allowedMethods"] = "GET,PUT,POST,DELETE,OPTIONS";
	res.headers["allowedOrigins"] = "*";
	res.headers["allowedHeaders"] = "Content-Type,Authorization,X-Requested-With,Content-Length,Accept,Origin";
	res.headers["allowCredentials"] = "true";
	*/
    res.headers["Access-Control-Allow-Origin"] = "*";
}

shared static this()
{
	auto api = new ProductAPIImpl;

	auto router = new URLRouter;
	router.any("*", &accessFilter);
	router.registerRestInterface(api);

	auto routes = router.getAllRoutes();

	auto settings = new HTTPServerSettings;
	settings.port = 8090;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.accessLogToConsole = true;
	listenHTTP(settings, router);

	logInfo("product-catalog-context active on port " ~ text(settings.port));

}
