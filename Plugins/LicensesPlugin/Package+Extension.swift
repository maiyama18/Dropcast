import Foundation
import PackagePlugin

extension Package: Hashable {
    public static func == (lhs: PackagePlugin.Package, rhs: PackagePlugin.Package) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Package {
    func getDependenciesRecursively() -> Set<Package> {
        var allDependencies: Set<Package> = .init()
        for dependency in dependencies {
            allDependencies.insert(dependency.package)
            allDependencies.formUnion(dependency.package.getDependenciesRecursively())
        }
        return allDependencies
    }
    
    func readLicenseText() -> String? {
        let licenseFilePath = directory.appending("LICENSE")
        guard FileManager.default.fileExists(atPath: licenseFilePath.string) else { return nil }
        return try? String(contentsOf: URL(fileURLWithPath: licenseFilePath.string))
    }
}
