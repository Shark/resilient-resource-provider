# resilient-resource-provider

## Goal
This project provides a proof-of-concept for a resilient resource provider architecture. The use case for such a design in a real world application is the integration of external services (e.g. a payment gateway) into a web application.

## Solution Requirements
- communicate with an external web service
- the client application should not directly depend on the external service
- the client application should be able to use the external service safely, i.e. a failure of the external service should not affect the availability or security of the client application

## Solution Architecture
### Software Design Patterns
- [**Microservices**](http://microservices.io)
- [**Loose Coupling**](https://en.wikipedia.org/wiki/Loose_coupling): The client application should not need to know how the underlying service works. It should be able to use the external service without leveraging knowledge about another domain ([DDD](https://en.wikipedia.org/wiki/Domain-driven_design)).
- [**Bulkheads**](https://johnragan.wordpress.com/2009/12/08/release-it-stability-patterns-and-best-practices/): A failure in one part of the client application should not propagate to other parts. The application should remain responsive even though some services may not be currently available. This is done by building separate compartments in the application which can fail individually (think of it as watertight bulkheads in ships or submarines).
  - [**API Gateway**](http://microservices.io/patterns/apigateway.html): the client application does not query the external service directly, but using an API Gateway in its own (application and runtime) domain
  - [**Circuit Breakers**](http://martinfowler.com/bliki/CircuitBreaker.html): the implementation of Circuit Breakers effectively allows the API Gateways to serve as Bulkheads. The API Gateways monitor if requests to the external service fail. If they do so continuously (e.g. the failure rate is over a given threshold), the Circuit Breaker is *opened* so that consecutive calls from the client application fail immediately. This allows the client application to remain responsive.

## License
This project is licensed under the Apache 2.0 License. See LICENSE for details.
