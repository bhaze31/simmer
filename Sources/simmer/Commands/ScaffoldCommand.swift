//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 10/15/22.
//

import ArgumentParser
import Foundation

final class ScaffoldCommand: ParsableCommand {
    static let _commandName: String = "scaffold"
    
    static let configuration = CommandConfiguration(abstract: "Generate a full suite of items for a model, including migrations, views, and controllers", usage: "How to use it", discussion: "How things work entirely")
    
    @Argument(help: "The name of the model to generate")
    private var name: String
    
    @Argument(help: "Fields to add to model")
    private var fields: [String]
    
    @Option(name: .shortAndLong, help: "Use a custom field for a model")
    private var customIdName: String?
    
    @Option(name: .shortAndLong, help: "Custom schema name.")
    private var schemaName: String?
    
    @Flag(name: [.long, .customShort("t")], help: "Don't use timestamps for model")
    private var skipTimestamps: Bool = false
    
    @Flag(name: [.long, .customShort("d")], help: "Use soft delete timestamp")
    private var softDelete: Bool = false
    
    func run() throws {
        let parsedFields = validateFields(fields: fields)
        
        let migrationOptions = MigrationOptions(
            name: name,
            fields: fields,
            skipTimestamps: skipTimestamps,
            softDelete: softDelete
        )
        
      
        
    }
}
