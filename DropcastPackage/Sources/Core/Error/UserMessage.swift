extension Error {
    public var userMessage: String {
        guard let hasMessage = self as? HasMessage else {
            return "Something went wrong"
        }
        return hasMessage.message
    }
}
