import Foundation
import PackagePlugin

@main struct Plugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        debugCurrentUser()
        try debugFileAttributes(path: context.pluginWorkDirectory.string)

        let childDirectory = context.pluginWorkDirectory.appending(["child"])
        try FileManager.default.createDirectoryIfNotExists(atPath: childDirectory.string)
        try debugFileAttributes(path: childDirectory.string)
        return []
    }

    func debugCurrentUser() {
        print("current user: \(NSUserName())")
    }

    func debugFileAttributes(path: String) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary

        let permissions = attributes.filePosixPermissions()
        let ownerPermission = (permissions >> 6) & 0x7
        let groupPermission = (permissions >> 3) & 0x7
        let otherPermission = permissions & 0x7

        let owner = attributes.fileOwnerAccountName() ?? "unknown"
        let group = attributes.fileGroupOwnerAccountName() ?? "unknown"

        print("\(path) \(ownerPermission)\(groupPermission)\(otherPermission) \(owner) \(group)")
    }
}

extension FileManager {
    func createDirectoryIfNotExists(atPath path: String) throws {
        guard !fileExists(atPath: path) else { return }
        try createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}
