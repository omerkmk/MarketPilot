# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

MarketPilot is a UIKit e-commerce portfolio/learning app (programmatic UI, no SwiftUI) backed by FakeStoreAPI (`https://fakestoreapi.com/products`). Per the README, the project is built with AI-assisted *mentoring*: AI explains concepts, reviews code and suggests improvements, while implementation is done by the author to ensure real understanding. Prefer explaining and reviewing over writing large amounts of code unless explicitly asked to implement something.

## Commands

No package manager or third-party dependencies; everything goes through Xcode / `xcodebuild`. Single scheme: `MarketPilot` (targets: `MarketPilot`, `MarketPilotTests`, `MarketPilotUITests`). Deployment target is iOS 18.5.

```bash
# Build
xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16' build

# All tests
xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16' test

# Single test (Target/Type/method)
xcodebuild ... test -only-testing:MarketPilotTests/MarketPilotTests/example
```

Unit tests use Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest. UI tests use XCTest.

The project uses Xcode file-system synchronized groups (`objectVersion = 77`), so new `.swift` files placed under `MarketPilot/` are picked up by the target automatically — no `project.pbxproj` edits needed.

## Architecture

Target architecture (from README): `ViewController → ViewModel → Repository → Service / Storage → Model`, with navigation owned by a coordinator (MVVM-C).

- **Composition root / navigation**: `SceneDelegate` builds the window programmatically and starts `App/AppCoordinator`. The coordinator creates all shared dependencies once (`ProductService`, `ProductRepository`, `ImageLoadingService`, `CartManager`, `FavoriteManager` with `UserDefaultsFavoriteStorage`) and injects them via initializers. View controllers never push other screens; they expose closures (`onProductSelected`, `onCartTapped`, `onFavoritesTapped`) that the coordinator wires to `show…` methods. `Main.storyboard` is still referenced in Info.plist but unused for the root UI; `ViewController.swift` is the leftover Xcode template.
- **Dependencies are protocol-typed** (`ProductServiceProtocol`, `ProductRepositoryProtocol`, `ImageLoadingServiceProtocol`, `CartManagerProtocol`, `FavoriteManagerProtocol`, `FavoriteStorageProtocol`) to allow test doubles. Shared managers are single instances passed to multiple screens, so cart/favorite state is shared across list, detail, cart and favorites.
- **MVVM migration is partial**: only the product list has a ViewModel. `ProductListViewModel` (`@MainActor`) holds `originalProducts` and derives `displayedProducts` by applying search text, category and `SortOption` in `applyFilters()`; it publishes `ProductListViewState` (`idle/loading/loaded/empty/error`) through the `onStateChanged` closure, and the VC toggles loading/empty/error views accordingly. Detail, Cart and Favorites view controllers still talk to their managers directly.
- **Features** live in `MarketPilot/Features/<Feature>/` with subfolders by role (`Models`, `Services`, `Repositories`, `Persistence`, `Views`, `List`, `Detail`).
- **Persistence**: favorites are persisted via `FavoriteStorageProtocol` (UserDefaults implementation); cart is in-memory only.
- **Images**: `ImageLoadingService` is async/await with an `NSCache` keyed by URL string. Cells own an `imageLoadingTask` that is cancelled in `prepareForReuse` to avoid showing stale images — follow this pattern for new cells that load images.
- Networking uses `URLSession.shared` + `async/await` with status-code validation and `JSONDecoder`; errors are currently logged with `print`.
