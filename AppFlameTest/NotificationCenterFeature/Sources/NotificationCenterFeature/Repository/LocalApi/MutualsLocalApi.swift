public class MutualsLocalApi : LocalApi {
    public typealias T = [LikeItem]?
    
    private var likeItems: [LikeItem]?
    
    public func createOrUpdate(data: [LikeItem]?) {
        likeItems = data
    }
    
    public func get() -> [LikeItem]? {
        likeItems
    }
    
    public func clear() {
        likeItems = nil
    }
}
