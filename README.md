# AppFlameTest

## Setup Instructions
1. **Clone the repository**  
   ```bash
   git clone <https://github.com/Irina0rlova/AppFlameTest.git>
2. **Open NotificationCenterFeature package in Xcode.**
3. Ensure iOS target ≥ 18.
4. **Dependencies**
   ```bash
   .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.12.0")
5. **Build & Run**  
   Use OutgoingLikesScreen:
   ``` OutgoingLikesScreen() ```  
7. **Tests** can be added via the NotificationCenterFeatureTests target.

## Architecture Summary
The project uses **MVVM** with **SwiftUI** and **TCA**

**Presentation:** SwiftUI + Composable Architecture (TCA)  
**Domain:** Reducers (NCReducer, LikedYouReducer, MutualsReducer) manage state, effects, and events.  
**Data:** Repository pattern for local + network storage.  
**Realtime**: Actor-based mock service using AsyncStream for event simulation.  
**Timer & Banner:** Managed in NCReducer with cancellable effects.  
**State Persistence:** NCStateStore persists unblur end date across app launches.

### Components
**UI Layer**  
- OutgoingLikesScreen: Root container view. Shows tabs for Liked You / Mutuals.
- LikedYouScreen: Displays grid of incoming likes.  
- MutualsScreen: Displays grid of mutual matches.  
- CardView: Represents a single like or mutual item.  
- GridView: Responsive grid layout for cards.  
- UnblurTimerView: Timer for unblurring items.  
- Mutual Match Banner: Notification UI for new mutual matches.

**Reducers**  
- NCReducer: Orchestrates LikedYouReducer + MutualsReducer. Handles:  
-- Real-time events  
-- Unblur timer  
-- Mutual match notifications  
- LikedYouReducer: Manages list of likes, pagination, blur/unblur states.  
- MutualsReducer: Manages mutual matches list.

**Repositories**
- LikeYouRepository: Fetches and caches likes.  
- Network Layer: LikeYouNetworkApi provides paginated API calls.  
- Local Cache: LikeLocalApi stores likes locally.  
- MutualsRepository: Actor storing mutual matches.  
- NCStateStore: Saves unblur end date in UserDefaults.

**Realtime Events**
- RealtimeEventsService: AsyncStream of events (likedYouInserted, mutualMatch).  
- Mock implementation for testing: MockRealtimeEventsService.

### Data Flow & API Contracts
``` LikedYouScreen → LikedYouReducer → NCReducer → LikeYouRepository → Network ```

- Network API: ``` fetchData(page: Int, batchSize: Int) -> (data: [UserModel], nextCursor: Int?) ```

- Mutual Match Notification  
--Triggered when .likeConfirmed in LikedYouReducer  
-- Updates MutualsReducer and shows banner  
- Realtime Events  
-- AsyncStream<RealtimeEvent> flows into NCReducer  
--Events:  
``` likedYouInserted(LikeItem)  ```  
``` mutualMatch(LikeItem) ```

**Pagination Model**
- Cursor-based pagination with nextCursor: Int?  
- batchSize configurable (default 10)  
- .loadNextPage fetches incrementally

**Sync Mechanisms**
- Initial load: Cached data if available, otherwise network fetch  
- Incremental updates: Via loadNextPage or real-time inserts  
- Real-time sync: AsyncStream events propagate immediately to reducers

**Caching**  
- Local cache (LikeLocalApi) stores [LikeItem] array  
- Invalidate on:   
-- Item removal  
-- Blur state changes  
- MutualsRepository stores in-memory only (can be persisted if needed)
