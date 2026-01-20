import Foundation
import GRDB

/// Represents a cannabis product with cannabinoid and terpene profile
struct Product: Codable, Identifiable, Hashable {
    var id: Int64?
    var name: String
    var brand: String?
    var type: ProductType
    var route: ConsumptionRoute

    // Cannabinoids (percentages)
    var thcPercent: Double?
    var cbdPercent: Double?
    var cbgPercent: Double?
    var thcvPercent: Double?

    // Terpenes (mg/g or percentages)
    var myrcene: Double?
    var limonene: Double?
    var pinene: Double?
    var caryophyllene: Double?
    var humulene: Double?
    var linalool: Double?
    var terpinolene: Double?
    var ocimene: Double?
    var otherTerpenes: String? // JSON string for additional terpenes

    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    enum ProductType: String, Codable {
        case flower
        case concentrate
        case edible
        case tincture
        case topical
        case vape
        case other
    }

    enum ConsumptionRoute: String, Codable {
        case inhalation
        case oral
        case sublingual
        case topical
    }

    init(
        id: Int64? = nil,
        name: String,
        brand: String? = nil,
        type: ProductType,
        route: ConsumptionRoute,
        thcPercent: Double? = nil,
        cbdPercent: Double? = nil,
        cbgPercent: Double? = nil,
        thcvPercent: Double? = nil,
        myrcene: Double? = nil,
        limonene: Double? = nil,
        pinene: Double? = nil,
        caryophyllene: Double? = nil,
        humulene: Double? = nil,
        linalool: Double? = nil,
        terpinolene: Double? = nil,
        ocimene: Double? = nil,
        otherTerpenes: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.type = type
        self.route = route
        self.thcPercent = thcPercent
        self.cbdPercent = cbdPercent
        self.cbgPercent = cbgPercent
        self.thcvPercent = thcvPercent
        self.myrcene = myrcene
        self.limonene = limonene
        self.pinene = pinene
        self.caryophyllene = caryophyllene
        self.humulene = humulene
        self.linalool = linalool
        self.terpinolene = terpinolene
        self.ocimene = ocimene
        self.otherTerpenes = otherTerpenes
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var cannabinoidSummary: String {
        var components: [String] = []
        if let thc = thcPercent { components.append("THC: \(String(format: "%.1f", thc))%") }
        if let cbd = cbdPercent { components.append("CBD: \(String(format: "%.1f", cbd))%") }
        if let cbg = cbgPercent { components.append("CBG: \(String(format: "%.1f", cbg))%") }
        if let thcv = thcvPercent { components.append("THCV: \(String(format: "%.1f", thcv))%") }
        return components.isEmpty ? "No cannabinoid data" : components.joined(separator: ", ")
    }

    var dominantTerpenes: [String] {
        let terpeneValues: [(String, Double)] = [
            ("Myrcene", myrcene ?? 0),
            ("Limonene", limonene ?? 0),
            ("Pinene", pinene ?? 0),
            ("Caryophyllene", caryophyllene ?? 0),
            ("Humulene", humulene ?? 0),
            ("Linalool", linalool ?? 0),
            ("Terpinolene", terpinolene ?? 0),
            ("Ocimene", ocimene ?? 0)
        ]

        return terpeneValues
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
    }
}

// MARK: - GRDB Persistence
extension Product: FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "products"

    enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let brand = Column("brand")
        static let type = Column("type")
        static let route = Column("route")
        static let thcPercent = Column("thcPercent")
        static let cbdPercent = Column("cbdPercent")
        static let cbgPercent = Column("cbgPercent")
        static let thcvPercent = Column("thcvPercent")
        static let myrcene = Column("myrcene")
        static let limonene = Column("limonene")
        static let pinene = Column("pinene")
        static let caryophyllene = Column("caryophyllene")
        static let humulene = Column("humulene")
        static let linalool = Column("linalool")
        static let terpinolene = Column("terpinolene")
        static let ocimene = Column("ocimene")
        static let otherTerpenes = Column("otherTerpenes")
        static let notes = Column("notes")
        static let createdAt = Column("createdAt")
        static let updatedAt = Column("updatedAt")
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
