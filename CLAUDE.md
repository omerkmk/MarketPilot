# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context
MarketPilot is a UIKit e-commerce portfolio/learning app (programmatic UI, no SwiftUI) backed by FakeStoreAPI (`https://fakestoreapi.com/products`).


## Commands

No package manager or third-party dependencies; everything goes through Xcode / `xcodebuild`. Single scheme: `MarketPilot` (targets: `MarketPilot`, `MarketPilotTests`, `MarketPilotUITests`). Deployment target is iOS 18.5.

```bash
# Build
xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5,arch=arm64' build

# All tests (parallel testing off: no cloned simulators)
xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5,arch=arm64' -parallel-testing-enabled NO test

# Single test (Target/Suite/function() — Swift Testing needs the parentheses)
xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5,arch=arm64' -parallel-testing-enabled NO test -only-testing:'MarketPilotTests/CartManagerTests/quantityIsZeroForProductNotInCart()'
```

Unit tests use Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest. UI tests use XCTest.

The project uses Xcode file-system synchronized groups (`objectVersion = 77`), so new `.swift` files placed under `MarketPilot/` are picked up by the target automatically — no `project.pbxproj` edits needed.

## Architecture

Target architecture (from README): `ViewController → ViewModel → Repository → Service / Storage → Model`, with navigation owned by a coordinator (MVVM-C).

- **Composition root / navigation**: `SceneDelegate` builds the window programmatically and starts `App/AppCoordinator`. The coordinator creates all shared dependencies once (`ProductService`, `ProductRepository`, `ImageLoadingService`, `CartManager`, `FavoriteManager` with `UserDefaultsFavoriteStorage`) and injects them via initializers. View controllers never push other screens; they expose closures (`onProductSelected`, `onCartTapped`, `onFavoritesTapped`) that the coordinator wires to `show…` methods. `Main.storyboard` is still referenced in Info.plist but unused for the root UI; `ViewController.swift` is the leftover Xcode template.
- **Dependencies are protocol-typed** (`ProductServiceProtocol`, `ProductRepositoryProtocol`, `ImageLoadingServiceProtocol`, `CartManagerProtocol`, `FavoriteManagerProtocol`, `FavoriteStorageProtocol`) to allow test doubles. Shared managers are single instances passed to multiple screens, so cart/favorite state is shared across list, detail, cart and favorites.
- **MVVM pattern**: `ProductListViewModel` is the reference implementation. New or migrated ViewModels follow it: `@MainActor final class`, dependencies injected as protocols via `init`, state exposed as `private(set)` and changed only through a private update method that calls an `on…Changed` closure. ViewControllers render state and forward user actions to the ViewModel. Some screens still call managers directly from the ViewController; don't copy that into new code.
- **Features** live in `MarketPilot/Features/<Feature>/` with subfolders by role (`Models`, `Services`, `Repositories`, `Persistence`, `Views`, `List`, `Detail`).
- **Persistence**: favorites are persisted via `FavoriteStorageProtocol` (UserDefaults implementation); cart is in-memory only.
- **Images**: `ImageLoadingService` is async/await with an `NSCache` keyed by URL string. Cells own an `imageLoadingTask` that is cancelled in `prepareForReuse` to avoid showing stale images — follow this pattern for new cells that load images.
- Networking uses `URLSession.shared` + `async/await` with status-code validation and `JSONDecoder`; errors are currently logged with `print`.
