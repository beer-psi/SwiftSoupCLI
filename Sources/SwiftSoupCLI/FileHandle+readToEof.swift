import Foundation

extension FileHandle {
    func readToEof() throws -> Data? {
        if #available(macOS 10.15.4, *) {
            return try readToEnd()
        } else {
            return readDataToEndOfFile()
        }
    }
}
