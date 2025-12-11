public protocol LocalApi {
    associatedtype T
    func createOrUpdate(data: T)
    func get() -> T
    func clear()
}
