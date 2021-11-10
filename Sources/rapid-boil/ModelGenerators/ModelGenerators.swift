import Foundation

final class ModelGenerator {
    public static func generateAPIRepresentable(for model: String) -> String {
        // TODO: Add fields to struct IndexContent
        // TODO: Add fields to struct GetContent
        // TODO: Add fields to struct PostContent
        // TODO: Add fields to struct PutContent

        return """
        import Vapor

        extension \(model): APIRepresentable {
            typealias Model = \(model)
            
            var indexContent: IndexContent { .init(with: self) }
            
            struct IndexContent: Content {
                init(with \(model.lowercased()): \(model)) {
                    
                }
            }
            
            var getContent: GetContent { .init(with: self) }
            
            struct GetContent: Content {
                init(with \(model.lowercased()): \(model)) {
                    
                }
            }
            
            struct PostContent: ValidatableContent {
                static func validations(_ validations: inout Validations) {
                    
                }
            }
            
            func create(_ content: PostContent) {
                
            }
            
            struct PutContent: ValidatableContent {
                static func validations(_ validations: inout Validations) {
                    
                }
            }
            
            func update(_ content: PutContent) throws {
                
            }
        }
        """
    }
    
    public static func generateWebRepresentable(for model: String) -> String {
        // TODO: Add fields to view context
        return """
        import Vapor

        extension \(model): WebRepresentable {
            var viewContext: ViewContext { .init(with: self) }
                
            var viewIdentifier: String { self.id!.uuidString }

            struct ViewContext: Encodable {
                init(with \(model.lowercased()): \(model)) {
                }
            }
        }
        """
    }
    
    public static func generateModel(name: String, fields: [String], hasTimestamps: Bool = true) -> String {
        if FileGenerator.fileExists(fileName: "\(name.capitalized).swift", path: .ModelPath) {
            fatalError("Model \(name.capitalized) already exists at path")
        }
        
        print("Generating model \(name.capitalized)")
        
        let fs = extractFieldsData(fields: fields)

        let initializer = generateModelInitializer(fields: fs)

        let fieldKeys = generateFieldKeys(fields: fs, hasTimestamps: hasTimestamps)

        // TODO: Implement check for Int id flag
        let modelFields = generateFields(fields: fs, hasTimestamps: hasTimestamps)
        var schema = name.lowercased()
        
        if schema.last != "s" {
            schema += "s"
        }

        let model = """
        import Vapor
        import Fluent
        
        final class \(name.capitalized): Model {
            static let schema = \"\(schema)\"
        
            struct FieldKeys {
                \(fieldKeys)
            }
        
            \(modelFields)
        
            init() {}
        
            \(initializer)
        }
        """
        
        return model
    }
}
