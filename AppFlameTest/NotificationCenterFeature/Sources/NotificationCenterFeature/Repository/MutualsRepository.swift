public actor MutualsRepository {
    private var mutuals: [LikeItem] = []
    
    public init() {}
    
    public func getData() -> [LikeItem] {
        mutuals.reversed()
    }
    
    public func addMutual(_ likeItem: LikeItem) {
        mutuals.append(likeItem)
    }
}
