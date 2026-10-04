---
paths:
  - "MarketPilotTests/**"
---

# Unit test conventions

- Use Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest. Group tests in a `struct` named `<TypeUnderTest>Tests`.
- Name tests as a sentence describing the behavior: `addingSameProductTwiceIncreasesQuantity`, not `testAdd2`.
- One behavior per test. Mark sections with `// Arrange`, `// Act`, `// Assert` comments.
- Create products with `Product.stub(id:price:)` from `MarketPilotTests/Helpers/Product+Stub.swift`. Don't build `Product(...)` inline; extend the stub if a new field is needed.
- Test doubles (fakes/spies for protocols like `FavoriteStorageProtocol`) live in `MarketPilotTests/Helpers/`.
- Cover edge cases, not only the happy path: product not in cart, quantity reaching zero, removing the last item.
