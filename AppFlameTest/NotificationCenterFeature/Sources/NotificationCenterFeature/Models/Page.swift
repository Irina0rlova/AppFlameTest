public struct Page<T: Equatable>: Equatable {
    public let items: [T]
    public let nextCursor: String?

    public init(items: [T], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}
