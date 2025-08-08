# A demonstration app of given task from go-dating.

## Architecture: Data Repository Layer

This app uses the **Repository Pattern** to abstract data access and business logic from the UI. The repository layer is responsible for:

- Coordinating between multiple data sources (local cache and remote API)

The repository implementation (`ProductRepository`) checks the local in-memory cache first for fast access, then fetches from a simulated remote API if the cache is empty or stale. This separation of concerns aligns with Clean Architecture principles, making the codebase modular and testable.

## State Management Solution

The app uses **Cubit** from the `flutter_bloc` package for state management. Cubit is a lightweight, reactive state management solution that is well-suited for handling asynchronous, multi-source data flows. It allows the UI to react to state changes (loading, fetching, up-to-date, error) and provides a clear separation between business logic and presentation. Cubit is ideal here because:

- It handles asynchronous events and state transitions cleanly
- It integrates well with streams from the repository
- It makes it easy to show different UI states (loading from cache, fetching from network, up-to-date, error)

## Caching and Staleness Detection Logic

- The app uses an **in-memory cache** (`InMemoryProductCache`) to store product data and the last update timestamp.
- When fetching products, the repository first checks the cache:
  - If the cache is empty or the data is older than 5 minutes (configurable), it is considered **stale** and a network fetch is triggered.
  - If the cache is fresh, it is used immediately for fast UI updates.
- The Cubit sets a timer after each fetch to automatically trigger a refresh when the cache becomes stale, as long as the app is open.
- This ensures the user always sees the most up-to-date data with minimal delay, and the UI clearly indicates whether data is being loaded from cache, fetched from the network, or is up-to-date.

---

## Notes

- I have added extra delay to see changes in UI in line number 88 of (`ProductRepository`) for loading data from cache
- Added an error IconButton in UI to show force error message and show local cache data.(`ProductCubit`) is handling state changes for this already.


Here is the apk : [https://drive.google.com/file/d/1M0QG9465nxl78IIY-0uY5v2-Jq49KhaJ/view?usp=drive_link]
Here is the video demo of the app: [https://drive.google.com/file/d/1izjT8zr7e0AoZ1CWo9vqBC2-Rktko-Fj/view?usp=drive_link]