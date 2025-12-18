import XCTest
@testable import NotificationCenterFeature

final class LikedYouMapperTests: XCTestCase {
    
    private var mapper: LikedYouMapper!
    
    override func setUp() {
        super.setUp()
        mapper = LikedYouMapper()
    }
    
    override func tearDown() {
        mapper = nil
        super.tearDown()
    }
    
    func test_map_nilInput_returnsEmptyArray() {
        // Given
        let input: [UserModel]? = nil
        
        // When
        let result = mapper.map(input)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_map_emptyArray_returnsEmptyArray() {
        // Given
        let input: [UserModel] = []
        
        // When
        let result = mapper.map(input)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_map_validUsers_mapsAllFieldsAndPreservesOrder() {
        // Given
        let id1 = UUID()
        let id2 = UUID()
        let user1 = UserModel(id: id1, userName: "Alice", avatarURL: "https://example.com/a.png")
        let user2 = UserModel(id: id2, userName: "Bob", avatarURL: "https://example.com/b.jpg")
        let input = [user1, user2]
        
        // When
        let result = mapper.map(input)
        
        // Then
        XCTAssertEqual(result.count, 2)
        
        // First item
        XCTAssertEqual(result[0].id, id1)
        XCTAssertEqual(result[0].userName, "Alice")
        XCTAssertEqual(result[0].avatarURL, URL(string: "https://example.com/a.png"))
        XCTAssertTrue(result[0].isBlurred)
        XCTAssertFalse(result[0].isReadOnly)
        
        // Second item
        XCTAssertEqual(result[1].id, id2)
        XCTAssertEqual(result[1].userName, "Bob")
        XCTAssertEqual(result[1].avatarURL, URL(string: "https://example.com/b.jpg"))
        XCTAssertTrue(result[1].isBlurred)
        XCTAssertFalse(result[1].isReadOnly)
    }
    
    func test_map_nilAvatarURL_resultsInNilURL() {
        // Given
        let user = UserModel(id: UUID(), userName: "No Avatar", avatarURL: nil)
        
        // When
        let result = mapper.map([user])
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].avatarURL, "URL(string: \"\") is nil, so avatarURL should be nil")
    }
}
