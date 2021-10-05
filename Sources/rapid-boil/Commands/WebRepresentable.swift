import ArgumentParser
import Foundation

struct WebRepresentable: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate a WebRepresentable version of a model"
    )
    
    @Argument(help: "Name of the model")
    private var model: String
    
    func run() throws {
        FileGenerator.createFileWithContents(
            "",
            fileName: "\(model)+WebRepresentable.swift",
            path: .ModelPath
        )
    }
}
