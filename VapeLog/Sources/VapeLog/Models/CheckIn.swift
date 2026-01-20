import Foundation
import GRDB

/// Represents a check-in after a session to record effects
struct CheckIn: Codable, Identifiable, Hashable {
    var id: Int64?
    var sessionId: Int64
    var minutesAfter: Int // 30, 60, or 120
    var timestamp: Date

    // Positive effects (0-10 scale)
    var awake: Int?
    var active: Int?
    var cerebral: Int?
    var social: Int?
    var euphoric: Int?
    var creative: Int?
    var focused: Int?

    // Negative effects (0-10 scale)
    var tired: Int?
    var groggy: Int?
    var anxious: Int?
    var antisocial: Int?
    var paranoia: Int?
    var dryMouth: Int?
    var dryEyes: Int?
    var racingHeart: Int?

    var notes: String?
    var createdAt: Date

    init(
        id: Int64? = nil,
        sessionId: Int64,
        minutesAfter: Int,
        timestamp: Date = Date(),
        awake: Int? = nil,
        active: Int? = nil,
        cerebral: Int? = nil,
        social: Int? = nil,
        euphoric: Int? = nil,
        creative: Int? = nil,
        focused: Int? = nil,
        tired: Int? = nil,
        groggy: Int? = nil,
        anxious: Int? = nil,
        antisocial: Int? = nil,
        paranoia: Int? = nil,
        dryMouth: Int? = nil,
        dryEyes: Int? = nil,
        racingHeart: Int? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.minutesAfter = minutesAfter
        self.timestamp = timestamp
        self.awake = awake
        self.active = active
        self.cerebral = cerebral
        self.social = social
        self.euphoric = euphoric
        self.creative = creative
        self.focused = focused
        self.tired = tired
        self.groggy = groggy
        self.anxious = anxious
        self.antisocial = antisocial
        self.paranoia = paranoia
        self.dryMouth = dryMouth
        self.dryEyes = dryEyes
        self.racingHeart = racingHeart
        self.notes = notes
        self.createdAt = createdAt
    }

    var positiveComposite: Double {
        let values = [awake, active, cerebral, social, euphoric, creative, focused].compactMap { $0 }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    var negativeComposite: Double {
        let values = [tired, groggy, anxious, antisocial, paranoia, dryMouth, dryEyes, racingHeart].compactMap { $0 }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}

// MARK: - GRDB Persistence
extension CheckIn: FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "check_ins"

    enum Columns {
        static let id = Column("id")
        static let sessionId = Column("sessionId")
        static let minutesAfter = Column("minutesAfter")
        static let timestamp = Column("timestamp")
        static let awake = Column("awake")
        static let active = Column("active")
        static let cerebral = Column("cerebral")
        static let social = Column("social")
        static let euphoric = Column("euphoric")
        static let creative = Column("creative")
        static let focused = Column("focused")
        static let tired = Column("tired")
        static let groggy = Column("groggy")
        static let anxious = Column("anxious")
        static let antisocial = Column("antisocial")
        static let paranoia = Column("paranoia")
        static let dryMouth = Column("dryMouth")
        static let dryEyes = Column("dryEyes")
        static let racingHeart = Column("racingHeart")
        static let notes = Column("notes")
        static let createdAt = Column("createdAt")
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    static let session = belongsTo(Session.self)
}
