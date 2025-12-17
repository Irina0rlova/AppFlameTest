import Foundation

public final class NCStateStore {
    private let unblurEndDateKey = "UnblurEndDate"
    
    public func saveUnblurEndDate(endDate: Date?) {
        UserDefaults.standard.set(endDate, forKey: unblurEndDateKey)
    }
    
    public func getUnblurEndDate() -> Date? {
        UserDefaults.standard.object(forKey: unblurEndDateKey) as? Date
    }
}
