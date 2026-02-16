final class MigrationLoader {
    static func loadAll(for options: MigrationOptions) {
        if options.isEmpty {
            generateEmptyMigration(options)
        } else {
            generateMigration(options)
        }
        
        if options.migrationType == .Create && !options.skipModel {
            createModel(options)
        }
	}
	
	static func generateMigration(_ options: MigrationOptions) {
        // TODO: Validate fields are all of okay type
        let fields: [Field] = options.fields.map { Field(field: $0) }
        
        var migrate = getMigrationSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync)
        migrate += "\n\t" + prepareMigration(options: options)
        
        if options.migrationType == .Create {
            // TODO: Allow custom ID types
            migrate += "\n\t\t\t.id()"
        }

        migrate = fields.reduce(migrate) { migration, nextField in
            return migration + "\n\t\t\t\(nextField.migrationField(options: options))"
        }
        
        var revert = getRevertSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync)
        revert += "\n\t" + prepareMigration(options: options)
        
        if [.Add, .Delete].contains(options.migrationType) {
            revert = fields.reduce(revert) { revert, nextField in
                return revert + "\n\t\t\t\(nextField.revertField(options: options))"
            }
        }
        
        if options.migrationType == .Create {
            migrate += "\n\t\t\t.create()"
            revert += "\n\t\t\t.delete()"
        } else {
            migrate += "\n\t\t\t.update()"
            revert += "\n\t\t\t.update()"
        }
        
        migrate += "\n\t}"
        revert += "\n\t}"

        let migration = getInitialMigrationFile(options: options)
            .swap("::migrate::", to: migrate)
            .swap("::revert::", to: revert)

        print(migration)
	}
    
    static func generateEmptyMigration(_ options: MigrationOptions) {
      
        let migrationName = "M\(options.timestamp)_\(options.name)"

        let migrationSignature = getMigrationSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync) + "}"
        
        let revertSignature = getRevertSignature(useAutoMigration: options.isAutoMigrate, useAsyncMigration: options.isAsync) + "}"
        
        let migration = getInitialMigrationFile(options: options)
            .swap("::migrate::", to: migrationSignature)
            .swap("::revert::", to: revertSignature)
            .swap("::migration_name::", to: migrationName)
        
      print(migration)
        FileHandler.createFileWithContents(
          migration,
          fileName: migrationName,
          path: PathGenerator.load(
            path: .Migrations,
            name: "App"
          )
        )
    }
    
    static func createModel(_ options: MigrationOptions) {
        let fields = validateFields(fields: options.fields)
        let modelOptions = ModelOptions(
            name: options.model,
            fields: fields,
            softDelete: options.modelOptions.softDelete,
            skipTimestamps: options.modelOptions.skipTimestamps
        )
        
        ModelLoader.generateModel(options: modelOptions)
    }
    
    static func getInitialMigrationFile(options: MigrationOptions) -> String {
        let imports = getImports(useAutoMigrator: options.isAutoMigrate)
        
        let migrationType = getMigrationType(
            useAutoMigrator: options.isAutoMigrate,
            useAsyncMigration: options.isAsync
        )
        
        let nameInfo = getNames(useAutoMigration: options.isAutoMigrate)
        

        let migration = FileHandler.fetchDefaultFile("Migration")
            .swap("::imports::", to: imports)
            .swap("::migration_type::", to: migrationType)
            .swap("::names::", to: nameInfo)
        
        return migration
    }
    
    static func getImports(useAutoMigrator: Bool) -> String {
        if useAutoMigrator {
            return "import Foundation\nimport Fluent\nimport AutoMigrator"
        }
        
        return "import Foundation\nimport Fluent"
    }
    
    static func getMigrationType(useAutoMigrator: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigrator, useAsyncMigration) {
            case (true, true):
                return "AsyncAutoMigration"
            case (true, false):
                return "AutoMigration"
            case (false, true):
                return "AsyncMigration"
            case (false, false):
                return "Migration"
        }
    }
    
    static func getNames(useAutoMigration: Bool) -> String {
        return useAutoMigration ?
            "\toverride var name: String { String(reflecting: self) }\n\toverride var defaultName: String { String(reflecting: self) }" :
            ""
        
    }
    
    static func getMigrationSignature(useAutoMigration: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigration, useAsyncMigration) {
            case (true, true):
                return "\toverride func prepare(on database: Database) async throws {"
            case (true, false):
                return "\toverride func prepare(on database: Database) -> EventLoopFuture<Void> {"
            case (false, true):
                return "\tfunc prepare(on database: Database) async throws {"
            case (false, false):
                return "\tfunc prepare(on database: Database) -> EventLoopFuture<Void> {"
        }
    }
    
    static func getRevertSignature(useAutoMigration: Bool, useAsyncMigration: Bool) -> String {
        switch (useAutoMigration, useAsyncMigration) {
            case (true, true):
                return "\toverride func revert(on database: Database) async throws {"
            case (true, false):
                return "\toverride func revert(on database: Database) -> EventLoopFuture<Void> {"
            case (false, true):
                return "\tfunc revert(on database: Database) async throws {"
            case (false, false):
                return "\tfunc revert(on database: Database) -> EventLoopFuture<Void> {"
        }
    }
    
    static func prepareMigration(options: MigrationOptions) -> String {
        if options.isAsync {
            return "\ttry await database.schema(\(options.model).schema)"
        }
        
        return "\tdatabase.schema(\(options.model).schema)"
    }
}

