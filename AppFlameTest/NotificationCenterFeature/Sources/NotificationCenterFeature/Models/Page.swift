public struct Page<T: Equatable & Sendable>: Equatable, Sendable {
    public let items: [T]
    public let nextCursor: Int?

    public init(items: [T], nextCursor: Int?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}
