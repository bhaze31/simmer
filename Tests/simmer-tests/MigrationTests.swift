//
//  MigrationTests.swift
//
//
//  Created by Brian Hasenstab on 10/7/22.
//

import XCTest
@testable import simmer

final class MigrationTests: XCTestCase {
    func testEmptyMigration() throws {
      let appName = "Testing"
      
      try? FileHandler.cleanup(app: PathGenerator.load(path: .Migrations, name: "App"))
      
      let modelOptions = MigrationModelOptions(softDelete: true, skipTimestamps: true)
      
      let options = MigrationOptions(
        name: "EmptyMigration",
        fields: [],
        model: nil,
        isAutoMigrate: true,
        isAsync: true,
        stringTypes: false,
        isEmpty: true,
        skipModel: true,
        modelOptions: modelOptions
      )
      
      MigrationLoader.loadAll(for: options)
      
      let appPath = PathGenerator.load(path: .Migrations, name: "App")
      
      let migrations = try FileManager.default.contentsOfDirectory(atPath: appPath)

      XCTAssertEqual(
          FileManager.default.fileExists(
              atPath: "\(appPath)/entrypoint.swift"
          ),
          true,
          "entrypoint.swift file should exist at path \(appPath)"
      )
    }

    func testEmptyMigrationWithModel() throws {}

    func testEmptyMigrationSkippingModel() throws {}
}
