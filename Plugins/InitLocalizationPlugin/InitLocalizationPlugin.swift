import Foundation
import PackagePlugin

@main
struct InitLocalizationPlugin: CommandPlugin {
    let fileManager: FileManager = .default
    let supportedLocales: [String] = ["en", "ja"]

    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        var argumentsExtractor = ArgumentExtractor(arguments)
        let targetStrings = argumentsExtractor.extractOption(named: "target")

        let targets = try context.package.targets(named: targetStrings)
        for target in targets {
            fileManager.createFileIfNotExists(
                atPath: target.directory.appending(["swiftgen.yml"]).string,
                contents: swiftgenYMLContent.data(using: .utf8)
            )

            let resourcesDirectory = target.directory.appending("Resources")
            for supportedLocale in supportedLocales {
                let localizationDirectory = resourcesDirectory.appending(["\(supportedLocale).lproj"])
                try fileManager.createDirectory(
                    atPath: localizationDirectory.string,
                    withIntermediateDirectories: true
                )

                fileManager.createFileIfNotExists(
                    atPath: localizationDirectory.appending(["Localizable.strings"]).string,
                    contents: nil
                )
            }

            print("Initialized resources directory for \(target.name)")
        }
    }
}

extension FileManager {
    func createFileIfNotExists(atPath path: String, contents: Data?) {
        guard !fileExists(atPath: path) else { return }
        createFile(atPath: path, contents: contents)
    }
}

let swiftgenYMLContent = """
input_dir: Resources
output_dir: ${DERIVED_SOURCES_DIR}
strings:
  inputs:
    - en.lproj/Localizable.strings
  outputs:
    - templateName: structured-swift5
      output: Strings+Generated.swift
"""
