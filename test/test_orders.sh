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
