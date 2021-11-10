import XCTest
@testable import rapid_boil

final class ScaffoldTests: XCTestCase {
    func testFieldGenerator() throws {
        let model = ModelGenerator.generateModel(name: "User", fields: ["name:string", "email:string", "username:string.a:o", "password:string"])
        
        XCTAssertEqual(model, """
        import Vapor
        import Fluent

        final class User: Model {
            static let schema = "users"

            struct FieldKeys {
                static var id: FieldKey { "id" }
                static var name: FieldKey { "name" }
                static var email: FieldKey { "email" }
                static var username: FieldKey { "username" }
                static var password: FieldKey { "password" }
                static var createdAt: FieldKey { "created_at" }
                static var updatedAt: FieldKey { "updated_at" }
            }

            @ID(key: FieldKeys.id) var id: UUID?
            @Field(key: FieldKeys.name) var name: String
            @Field(key: FieldKeys.email) var email: String
            @Field(key: FieldKeys.username) var username: [String]?
            @Field(key: FieldKeys.password) var password: String
            @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
            @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?

            init() {}

            init(name: String, email: String, username: [String]?, password: String) {
                self.name = name
                self.email = email
                self.username = username
                self.password = password
            }
        }
        """)
    }
}
