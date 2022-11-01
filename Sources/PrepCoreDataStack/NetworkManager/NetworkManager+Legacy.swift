//import Foundation
//
//public struct PageMetadata: Codable {
//    public let page: Int
//    public let per: Int
//    public let total: Int
//
//    var hasMorePages: Bool {
//        total > page * per
//    }
//}
//
//public struct FoodsPage: Codable {
//    public let items: [FoodSearchResult]
//    public let metadata: PageMetadata
//
//    public var hasMorePages: Bool {
//        metadata.hasMorePages
//    }
//}
