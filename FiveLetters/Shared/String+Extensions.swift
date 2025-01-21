import Foundation

extension String {
    /// Sicherer Zugriff auf einen Character an einem bestimmten Index
    func characterAt(_ index: Int) -> Character {
        guard index >= 0, index < count else { return "•" }
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    /// Sicherer Zugriff auf einen Substring von Start bis Ende
    func substring(from: Int, to: Int) -> Substring {
        let start = index(startIndex, offsetBy: max(0, from))
        let end = index(startIndex, offsetBy: min(count, to))
        return self[start..<end]
    }
} 