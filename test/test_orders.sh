echo
echo "Sending orders: "
curl \
  -H "Content-Type: application/json" \
  -d @orders.json \
  http://127.0.0.1:8070/service/order-requests
echo
echo
echo "Querying orders: "
curl http://127.0.0.1:8070/service/query/orders
echo
echo
echo "Querying events: "
curl http://127.0.0.1:8070/service/query/events
echo
echo
echo "Activating order: "
curl \
-H "Content-Type: application/json" \
  -d '{ "orderId": "45f3b938-9107-4c9c-853c-a6a75ed173c5" }' \
  http://127.0.0.1:8070/service/order-requests/activations
echo
echo
echo "Querying orders: "
curl http://127.0.0.1:8070/service/query/orders
echo
echo
echo "Querying events: "
curl http://127.0.0.1:8070/service/query/events
echo
echo
