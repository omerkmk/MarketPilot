# MarketPilot

MarketPilot is a UIKit-based e-commerce portfolio app built with programmatic UI.

The main goal of this project is to learn and demonstrate real-world iOS development practices through a portfolio-level application.

## Current Status

- UIKit project setup completed
- Programmatic root setup completed
- AppCoordinator added
- ProductListViewController added
- UICollectionView skeleton added
- Temporary product cells displayed using UICollectionViewDataSource
- Cell selection handled using UICollectionViewDelegate

## Tech Stack

- Swift
- UIKit
- Programmatic UI
- Auto Layout
- MVVM-C
- Repository Pattern
- Service Layer
- FakeStoreAPI

## Planned Features

- Product List
- Product Detail
- Search
- Category Filter
- Sort
- Favorites
- Cart
- Local Persistence
- Loading / Error / Empty States
- Unit Tests

## Architecture Goal

```text
ViewController
↓
ViewModel
↓
Repository
↓
Service / Storage
↓
Model
```

## Navigation Flow

```text
SceneDelegate
↓
AppCoordinator
↓
UINavigationController
↓
ProductListViewController
```

## Learning Goals

This project is also used as a learning roadmap for the following topics:

- Swift fundamentals
- UIKit
- Programmatic UI
- Auto Layout
- UICollectionView
- Delegate Pattern
- Protocols
- MVVM
- Coordinator Pattern
- Repository Pattern
- Service Layer
- Networking
- Clean Code
- SOLID Principles
- Unit Testing
- Git and GitHub

## AI-Assisted Development Workflow

This project is developed with AI-assisted mentoring and code review.

AI is used to explain concepts, review code, suggest improvements, and support learning.

Implementation decisions and code writing are done manually to ensure real understanding.

## API

FakeStoreAPI  
https://fakestoreapi.com
