import Foundation
import PackagePlugin

@main struct Plugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let dependencies = context.package.getDependenciesRecursively()
        let generatedLicensesText = dependencies.map {
            let licenseText = $0.readLicenseText() ?? "nil"
            return """
            License(
                name: \"\($0.displayName)\",
                licenseText: \"\"\"
            \(licenseText)
            \"\"\"
            )
            """
        }.joined(separator: ",\n")
        
        let generatedFileContent = """
        struct License {
            let name: String
            let licenseText: String
        }
        
        enum LicensesPlugin {
            static let licenses: [License] = [
                \(generatedLicensesText)
            ]
        }
        """
        
        let tmpOutputFilePathString = try tmpOutputFilePath(workDirectory: context.pluginWorkDirectory).string
        try generatedFileContent.write(to: URL(fileURLWithPath: tmpOutputFilePathString), atomically: true, encoding: .utf8)
        
        let outputFilePath = try outputFilePath(workDirectory: context.pluginWorkDirectory)
        
        return [
            .prebuildCommand(
                displayName: "LicensesPlugin",
                executable: try context.tool(named: "cp").path,
                arguments: [tmpOutputFilePathString, outputFilePath.string],
                outputFilesDirectory: outputFilePath.removingLastComponent()
            )
        ]
    }
    
    private let generatedFileName = "Licenses+Generated.swift"
    
    private func tmpOutputFilePath(workDirectory: Path) throws -> Path {
        let tmpDirectory = workDirectory.appending("Tmp")
        try FileManager.default.createDirectoryIfNotExists(atPath: tmpDirectory.string)
        return tmpDirectory.appending(generatedFileName)
    }
    
    private func outputFilePath(workDirectory: Path) throws -> Path {
        let outputDirectory = workDirectory.appending("Output")
        try FileManager.default.createDirectoryIfNotExists(atPath: outputDirectory.string)
        return outputDirectory.appending("Licenses+Generated.swift")
    }
}
