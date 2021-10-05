import Foundation

final class ModelGenerator {
    public static func generateAPIRepresentable(for model: String) {
        
    }
    
    public static func generateWebRepresentable(for model: String) {
        
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
        
        let model = """
        import Vapor
        import Fluent
        
        final class \(name.capitalized): Model {
            static let schema = \"\(name.lowercased())\"
        
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