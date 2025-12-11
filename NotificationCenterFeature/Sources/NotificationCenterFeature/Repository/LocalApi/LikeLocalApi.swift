public class LikeLocalApi : LocalApi {
    public typealias T = [LikeItem]?
    private var likeItems: [LikeItem]?

    public func createOrUpdate(data: [LikeItem]?) {
        likeItems = data
    }
    
    public func get() -> [LikeItem]? {
        guard let likeItems else {
            return nil
        }
        
        return likeItems
    }
    
    public func clear() {
        likeItems = nil
    }
}
