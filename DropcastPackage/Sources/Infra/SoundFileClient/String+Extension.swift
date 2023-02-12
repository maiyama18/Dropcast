import Foundation

extension String {
    init?(base64Encoded: String) {
        guard let base64EncodedData = base64Encoded.data(using: .utf8),
              let data = Data(base64Encoded: base64EncodedData),
              let string = String(data: data, encoding: .utf8) else { return nil }
        
        self = string
    }
    
    func base64Encoded() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }
}
