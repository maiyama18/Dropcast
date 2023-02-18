import CustomDump

public func customDump<T>(
  _ value: T,
  name: String? = nil,
  indent: Int = 0,
  maxDepth: Int = .max
) -> String {
    var string = ""
    customDump(value, to: &string, name: name, indent: indent, maxDepth: maxDepth)
    return string
}
