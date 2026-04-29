import Foundation

final class NotepadContent: ObservableObject {
    static let shared = NotepadContent()
    private static let key = "notepad.content"

    @Published var text: String {
        didSet { UserDefaults.standard.set(text, forKey: Self.key) }
    }

    private init() {
        text = UserDefaults.standard.string(forKey: Self.key) ?? ""
    }
}
