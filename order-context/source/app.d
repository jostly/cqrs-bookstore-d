import std.conv, std.uuid, std.datetime, core.time;
import vibe.d;
import bookstore.ordercontext;
import cqrslib.dispatcher;
import cqrslib.bus;

void accessFilter(HTTPServerRequest req, HTTPServerResponse res)
{
    res.headers["Access-Control-Allow-Origin"] = "*";
    res.headers["Access-Control-Allow-Methods"] = "GET,PUT,POST,DELETE,OPTIONS";
    res.headers["Access-Control-Allow-Headers"] = "Content-Type,Authorization,X-Requested-With,Content-Length,Accept,Origin";
    res.headers["Access-Control-Allow-Credentials"] = "true"; 
}

void sendOptions(HTTPServerRequest req, HTTPServerResponse res)
{
    accessFilter(req, res);
    res.writeBody("");
}

shared static this()
{
	logInfo("Booting on " ~ currentThreadId());
	
	auto commandBus = new AsynchronousBus();
	auto eventBus = new AsynchronousDomainEventBus();
	
	auto domainEventStore = new InMemoryDomainEventStore();
	
	auto aggregateRepository = new Repository(domainEventStore, eventBus);

	auto orderCommandHandler = new immutable OrderCommandHandler(aggregateRepository);
	commandBus.registerHandler(orderCommandHandler);

	auto orderProjectionRepository = new InMemoryOrderProjectionRepository();

	auto orderListDenormalizer = new OrderListDenormalizer(orderProjectionRepository);
	eventBus.register(orderListDenormalizer);
	
	auto productCatalogClient = new ProductCatalogClient("http://127.0.0.1:8090/");

	auto queryService = new QueryService(orderListDenormalizer, productCatalogClient);

	auto router = new URLRouter;
	router.any("*", &accessFilter);
	router.match(HTTPMethod.OPTIONS, "*", &sendOptions);
	router.get("*", serveStaticFiles("assets/"));
	
	router.registerRestInterface(new QueryResource(queryService, domainEventStore), "/service/query");
	router.registerRestInterface(new OrderResource(commandBus), "/service/order-requests");

	auto settings = new HTTPServerSettings;
	settings.port = 8070;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.accessLogToConsole = true; // Log all access to the console
	listenHTTP(settings, router);

	auto routes = router.getAllRoutes();
    logInfo("Available routes: "~text(routes));
    
	logInfo("\n- order-context active on port " ~ text(settings.port) ~ " -\n");
}
