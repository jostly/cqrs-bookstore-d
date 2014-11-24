import std.conv, std.uuid, std.datetime, core.time;
import vibe.d;
import bookstore.ordercontext;
import cqrslib.dispatcher;

void accessFilter(HTTPServerRequest req, HTTPServerResponse res)
{
    res.headers["Access-Control-Allow-Origin"] = "*";
}

shared static this()
{
	auto commandBus = new SynchronousDispatcher();
	auto eventBus = new SynchronousDispatcher();
	
	auto domainEventStore = new InMemoryDomainEventStore();
	
	auto aggregateRepository = new Repository(domainEventStore, eventBus);

	auto orderCommandHandler = new OrderCommandHandler(aggregateRepository);
	commandBus.register(&orderCommandHandler.handlePlaceOrderCommand);

	auto orderProjectionRepository = new InMemoryOrderProjectionRepository();

	auto orderListDenormalizer = new OrderListDenormalizer(orderProjectionRepository);

	auto queryService = new QueryService(orderListDenormalizer);

	auto router = new URLRouter;
	router.any("*", &accessFilter);
	
	router.registerRestInterface(new QueryResource(queryService, domainEventStore), "/service/query");
	router.registerRestInterface(new OrderResource(commandBus), "/service/order-requests");

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.accessLogToConsole = true; // Log all access to the console
	listenHTTP(settings, router);

	auto routes = router.getAllRoutes();
    logInfo("Available routes: "~text(routes));
    
	logInfo("\n- order-context active on port " ~ text(settings.port) ~ " -\n");
}
