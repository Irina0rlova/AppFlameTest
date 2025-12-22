import Foundation

public class LikedYouMapper {
    func map(_ networkData: [UserModel]?) -> [LikeItem] {
        guard let networkData else { return [] }
        
        return networkData.map { user in
            LikeItem(
                id: user.id,
                userName: user.userName,
                avatarURL: URL(string: user.avatarURL ?? ""),
                isBlurred: true,
                isReadOnly: false
            )
        }
    }
}
