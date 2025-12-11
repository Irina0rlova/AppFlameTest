public class LikeLocalApi : LocalApi {
    public typealias T = [LikeItem]?
    private var likeItems: [LikeItem]?

    public func createOrUpdate(data: [LikeItem]?) {
        guard likeItems != nil else {
            likeItems = data
            return
        }
        
        likeItems!.append(contentsOf: data ?? [])
    }
    
    public func get() -> [LikeItem]? {
        likeItems
    }
    
    public func clear() {
        likeItems = nil
    }
}

// LikeLocalApi is a class with internal mutable state and is not thread-safe.
// We mark it as @unchecked Sendable under the assumption it is only accessed
// from a single executor or otherwise externally synchronized.
extension LikeLocalApi: @unchecked Sendable {}
