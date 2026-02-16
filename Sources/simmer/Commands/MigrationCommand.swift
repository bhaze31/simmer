import Foundation
import ArgumentParser

enum MigrationType {
    case Add
    case Delete
    case Create
    case Unknown
}

struct MigrationModelOptions {
    var softDelete: Bool
    var skipTimestamps: Bool
    var schemaName: String?
}

struct MigrationOptions {
    var name: String
    var timestamp: String
    var migrationType: MigrationType
    var fields: [String]
    var model: String
    var isAutoMigrate: Bool
    var isAsync: Bool
    var stringTypes: Bool
    var isEmpty: Bool
    var skipModel: Bool
    var modelOptions: MigrationModelOptions
    var customIdName: String?
    
    init(name: String, fields: [String], model: String?, isAutoMigrate: Bool, isAsync: Bool, stringTypes: Bool, isEmpty: Bool, skipModel: Bool, modelOptions: MigrationModelOptions) {
        self.fields = fields
        
        if name.starts(with: "Add") {
            let parts = name.components(separatedBy: "To")
            self.migrationType = .Add
            self.model = parts.last!
            
            if parts.count == 2, var field = parts.first {
                field.removeFirst(3)
                self.fields.append("\(field.lowercased()):string")
            }
        } else if name.starts(with: "Remove") || name.starts(with: "Delete") {
            let parts = name.components(separatedBy: "From")
            migrationType = .Delete
            self.model = parts.last!
            
            if parts.count == 2, var field = parts.first {
                field.removeFirst(6)
                self.fields.append("\(field.lowercased()):string")
            }
        } else if name.starts(with: "Create") {
            migrationType = .Create
            
            self.model = name
            self.model.removeFirst(6)
        } else {
            migrationType = .Unknown
            self.model = name
        }
        
        if let _model = model {
            self.model = _model
        }
        
        self.timestamp = getTimestamp()
        self.name = name
        self.isAutoMigrate = isAutoMigrate
        self.isAsync = isAsync
        self.stringTypes = stringTypes
        self.isEmpty = isEmpty
        self.skipModel = skipModel
        
        self.modelOptions = modelOptions
        
        if let field = extractDefaultField(name: name) {
            self.fields.append(field)
        }
    }
    
    init(name: String, fields: [String], skipTimestamps: Bool, softDelete: Bool) {
        self.name = "Create\(name.toCamelCase().uppercased())"
        self.migrationType = .Create
        self.fields = fields
        self.model = name
        self.isAutoMigrate = true
        self.isAsync = true
        self.stringTypes = false
        self.isEmpty = false
        self.timestamp = getTimestamp()
        self.modelOptions = MigrationModelOptions(softDelete: softDelete, skipTimestamps: skipTimestamps)
        self.skipModel = false
        self.timestamp = getTimestamp()
    }
    
    func extractDefaultField(name: String) -> String? {
        if name.starts(with: "Add") {
            
        } else if name.starts(with: "Delete") || name.starts(with: "Remove") {
            
        } else if name.starts(with: "Create") {
            
        }
        
        return nil
    }
}

final class MigrationCommand: ParsableCommand {
    static let _commandName: String = "migration"

    static let configuration = CommandConfiguration(
        abstract: "Generate a stand-alone migration",
        discussion: """
        To automate the process, pass the name as [Add/Delete][Field][To/From][Model]. If for example you wanted to remove the field nickname from a model User, it would be migration DeleteNicknameFromUser. If you wanted to add a field called username, you would use migration AddUsernameToUser username:string. Note that you need to add the field name you want along with its type.
        
        If you just want to generate an empty migration, you can use any name for your migration and pass --empty.\nIf you have a different naming convention for migration, you can specify the model and type using --model [ModelName] --migration-type [Add/Delete]. MigrationType defaults to Add.
        
        If you want to simply add a new model, use the format Create[Model]. This will work by creating the table instead of updating it, including ID fields. Similarly, use Drop[Model] to delete the table.
        
        For all options, refer to the manual at simmer manual.
        """
    )

    @Argument(help: "The name of the migration to generate")
    private var name: String
    
    @Argument(help: "Fields for migration")
    private var fields: [String] = []
    
    @Option(help: "The name of the model to use, if not defined in the migration name")
    private var model: String?
    
    @Flag(name: .shortAndLong, help: "Generate an empty migration")
    private var empty = false
    
    @Flag(name: [.customShort("m"), .long], help: "Use AutoMigrate class for migrations")
    private var autoMigrate = false
    
    @Flag(name: [.customShort("a"), .customLong("async")], inversion: .prefixedNo, help: "Create an async migration")
    private var isAsync = true
    
    @Flag(name: .shortAndLong, help: "Use strings for the migration field name as opposed to field keys")
    private var stringTypes = false
    
    @Flag(name: .long, help: "Skip model generation if migration type is Create")
    private var skipModel = false
    
    @Flag(name: [.long, .customShort("d")], help: "If creating a model, use soft delete for this model")
     private var softDelete = false

    @Flag(name: [.long, .customShort("t")], help: "Skip timestamps if the creating a model")
    private var skipTimestamps = false
    
    func run() throws {
        let modelOptions = MigrationModelOptions(softDelete: softDelete, skipTimestamps: skipTimestamps)

        let options = MigrationOptions(
            name: name,
            fields: fields,
            model: model,
            isAutoMigrate: autoMigrate,
            isAsync: isAsync,
            stringTypes: stringTypes,
            isEmpty: empty,
            skipModel: skipModel,
            modelOptions: modelOptions
        )

        MigrationLoader.loadAll(for: options)
    }
}
