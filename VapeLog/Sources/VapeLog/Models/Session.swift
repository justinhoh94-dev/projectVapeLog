import Foundation
import GRDB

/// Represents a cannabis usage session
struct Session: Codable, Identifiable, Hashable {
    var id: Int64?
    var productId: Int64
    var dateTime: Date
    var doseMg: Double?
    var doseUnits: String? // "mg", "g", "puffs", etc.

    // Context
    var location: String?
    var withCompany: Bool
    var hadCaffeine: Bool
    var hadAlcohol: Bool
    var hadFood: Bool
    var sleepQuality: Int? // 1-5 scale

    // Pre-session state
    var preMood: Int? // 1-10 scale
    var preStress: Int? // 1-10 scale

    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: Int64? = nil,
        productId: Int64,
        dateTime: Date = Date(),
        doseMg: Double? = nil,
        doseUnits: String? = nil,
        location: String? = nil,
        withCompany: Bool = false,
        hadCaffeine: Bool = false,
        hadAlcohol: Bool = false,
        hadFood: Bool = false,
        sleepQuality: Int? = nil,
        preMood: Int? = nil,
        preStress: Int? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.dateTime = dateTime
        self.doseMg = doseMg
        self.doseUnits = doseUnits
        self.location = location
        self.withCompany = withCompany
        self.hadCaffeine = hadCaffeine
        self.hadAlcohol = hadAlcohol
        self.hadFood = hadFood
        self.sleepQuality = sleepQuality
        self.preMood = preMood
        self.preStress = preStress
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - GRDB Persistence
extension Session: FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "sessions"

    enum Columns {
        static let id = Column("id")
        static let productId = Column("productId")
        static let dateTime = Column("dateTime")
        static let doseMg = Column("doseMg")
        static let doseUnits = Column("doseUnits")
        static let location = Column("location")
        static let withCompany = Column("withCompany")
        static let hadCaffeine = Column("hadCaffeine")
        static let hadAlcohol = Column("hadAlcohol")
        static let hadFood = Column("hadFood")
        static let sleepQuality = Column("sleepQuality")
        static let preMood = Column("preMood")
        static let preStress = Column("preStress")
        static let notes = Column("notes")
        static let createdAt = Column("createdAt")
        static let updatedAt = Column("updatedAt")
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    static let product = belongsTo(Product.self)
    static let checkIns = hasMany(CheckIn.self)
}

// MARK: - Session with Product
struct SessionWithProduct: Decodable, FetchableRecord {
    var session: Session
    var product: Product

    static func all() -> QueryInterfaceRequest<SessionWithProduct> {
        let sessionAlias = TableAlias()
        let productAlias = TableAlias()

        return Session
            .aliased(sessionAlias)
            .including(required: Session.product.aliased(productAlias))
            .asRequest(of: SessionWithProduct.self)
    }
}
