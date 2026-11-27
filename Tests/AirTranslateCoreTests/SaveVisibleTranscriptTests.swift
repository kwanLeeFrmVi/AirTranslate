import Foundation
import Testing
@testable import AirTranslate

@Suite(.serialized)
@MainActor
struct SaveVisibleTranscriptTests {
    @Test func savesOriginalAndTranslationFiles() throws {
        let name = "SaveVisibleTranscriptTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        defer {
            defaults.removePersistentDomain(forName: name)
            try? FileManager.default.removeItem(at: directory)
        }
        let session = TranslationSessionStore(modelAvailabilityProvider: { _, _ in [:] },
            settingsDefaults: defaults, transcriptsDirectoryURL: directory)
        #expect(!session.canSaveVisibleTranscript)

        session.lines = [
            CaptionLine(sourceText: "Sell your house.", translatedText: "Bán nhà đi.", createdAt: Date(), isFinal: true),
            CaptionLine(sourceText: "Fine, okay.", translatedText: "", createdAt: Date(), isFinal: true),
        ]
        #expect(session.canSaveVisibleTranscript)
        #expect(session.saveVisibleTranscript())

        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let texts = try files.map { try String(contentsOf: $0, encoding: .utf8) }
        #expect(texts.contains { $0.contains("Sell your house.") && $0.contains("Fine, okay.") })
        #expect(texts.contains { $0.contains("Bán nhà đi.") })
    }
}
