import Foundation
import GRDB

/// Manages the local SQLite database using GRDB
final class DatabaseService {
    static let shared = DatabaseService()

    private var dbQueue: DatabaseQueue!

    private init() {
        do {
            let fileManager = FileManager.default
            let documentsPath = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dbPath = documentsPath.appendingPathComponent("vapelog.sqlite").path

            dbQueue = try DatabaseQueue(path: dbPath)

            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Database initialization failed: \(error)")
        }
    }

    // MARK: - Migrations
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_initial_schema") { db in
            // Products table
            try db.create(table: "products") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("brand", .text)
                t.column("type", .text).notNull()
                t.column("route", .text).notNull()

                // Cannabinoids
                t.column("thcPercent", .double)
                t.column("cbdPercent", .double)
                t.column("cbgPercent", .double)
                t.column("thcvPercent", .double)

                // Terpenes
                t.column("myrcene", .double)
                t.column("limonene", .double)
                t.column("pinene", .double)
                t.column("caryophyllene", .double)
                t.column("humulene", .double)
                t.column("linalool", .double)
                t.column("terpinolene", .double)
                t.column("ocimene", .double)
                t.column("otherTerpenes", .text)

                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }

            // Sessions table
            try db.create(table: "sessions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("productId", .integer).notNull()
                    .references("products", onDelete: .cascade)
                t.column("dateTime", .datetime).notNull()
                t.column("doseMg", .double)
                t.column("doseUnits", .text)

                // Context
                t.column("location", .text)
                t.column("withCompany", .boolean).notNull().defaults(to: false)
                t.column("hadCaffeine", .boolean).notNull().defaults(to: false)
                t.column("hadAlcohol", .boolean).notNull().defaults(to: false)
                t.column("hadFood", .boolean).notNull().defaults(to: false)
                t.column("sleepQuality", .integer)

                // Pre-session state
                t.column("preMood", .integer)
                t.column("preStress", .integer)

                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }

            try db.create(index: "sessions_productId", on: "sessions", columns: ["productId"])
            try db.create(index: "sessions_dateTime", on: "sessions", columns: ["dateTime"])

            // Check-ins table
            try db.create(table: "check_ins") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sessionId", .integer).notNull()
                    .references("sessions", onDelete: .cascade)
                t.column("minutesAfter", .integer).notNull()
                t.column("timestamp", .datetime).notNull()

                // Positive effects
                t.column("awake", .integer)
                t.column("active", .integer)
                t.column("cerebral", .integer)
                t.column("social", .integer)
                t.column("euphoric", .integer)
                t.column("creative", .integer)
                t.column("focused", .integer)

                // Negative effects
                t.column("tired", .integer)
                t.column("groggy", .integer)
                t.column("anxious", .integer)
                t.column("antisocial", .integer)
                t.column("paranoia", .integer)
                t.column("dryMouth", .integer)
                t.column("dryEyes", .integer)
                t.column("racingHeart", .integer)

                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull()
            }

            try db.create(index: "check_ins_sessionId", on: "check_ins", columns: ["sessionId"])
        }

        return migrator
    }

    // MARK: - Product Operations
    func createProduct(_ product: Product) throws -> Product {
        var newProduct = product
        try dbQueue.write { db in
            try newProduct.insert(db)
        }
        return newProduct
    }

    func getProduct(id: Int64) throws -> Product? {
        try dbQueue.read { db in
            try Product.fetchOne(db, key: id)
        }
    }

    func getAllProducts() throws -> [Product] {
        try dbQueue.read { db in
            try Product.order(Product.Columns.createdAt.desc).fetchAll(db)
        }
    }

    func updateProduct(_ product: Product) throws {
        var updatedProduct = product
        updatedProduct.updatedAt = Date()
        try dbQueue.write { db in
            try updatedProduct.update(db)
        }
    }

    func deleteProduct(id: Int64) throws {
        try dbQueue.write { db in
            try Product.deleteOne(db, key: id)
        }
    }

    // MARK: - Session Operations
    func createSession(_ session: Session) throws -> Session {
        var newSession = session
        try dbQueue.write { db in
            try newSession.insert(db)
        }
        return newSession
    }

    func getSession(id: Int64) throws -> Session? {
        try dbQueue.read { db in
            try Session.fetchOne(db, key: id)
        }
    }

    func getAllSessions() throws -> [Session] {
        try dbQueue.read { db in
            try Session.order(Session.Columns.dateTime.desc).fetchAll(db)
        }
    }

    func getSessionsWithProducts() throws -> [SessionWithProduct] {
        try dbQueue.read { db in
            try SessionWithProduct.all()
                .order(Session.Columns.dateTime.desc)
                .fetchAll(db)
        }
    }

    func updateSession(_ session: Session) throws {
        var updatedSession = session
        updatedSession.updatedAt = Date()
        try dbQueue.write { db in
            try updatedSession.update(db)
        }
    }

    func deleteSession(id: Int64) throws {
        try dbQueue.write { db in
            try Session.deleteOne(db, key: id)
        }
    }

    func getSessionCount() throws -> Int {
        try dbQueue.read { db in
            try Session.fetchCount(db)
        }
    }

    // MARK: - CheckIn Operations
    func createCheckIn(_ checkIn: CheckIn) throws -> CheckIn {
        var newCheckIn = checkIn
        try dbQueue.write { db in
            try newCheckIn.insert(db)
        }
        return newCheckIn
    }

    func getCheckIn(id: Int64) throws -> CheckIn? {
        try dbQueue.read { db in
            try CheckIn.fetchOne(db, key: id)
        }
    }

    func getCheckIns(forSession sessionId: Int64) throws -> [CheckIn] {
        try dbQueue.read { db in
            try CheckIn
                .filter(CheckIn.Columns.sessionId == sessionId)
                .order(CheckIn.Columns.minutesAfter)
                .fetchAll(db)
        }
    }

    func updateCheckIn(_ checkIn: CheckIn) throws {
        try dbQueue.write { db in
            try checkIn.update(db)
        }
    }

    func deleteCheckIn(id: Int64) throws {
        try dbQueue.write { db in
            try CheckIn.deleteOne(db, key: id)
        }
    }

    // MARK: - Analytics Queries
    func getSessionCountForMLReadiness() throws -> Int {
        try getSessionCount()
    }

    func getAverageEffectsForProduct(productId: Int64) throws -> (positive: Double, negative: Double)? {
        try dbQueue.read { db in
            let sessions = try Session
                .filter(Session.Columns.productId == productId)
                .fetchAll(db)

            guard !sessions.isEmpty else { return nil }

            var positiveSum: Double = 0
            var negativeSum: Double = 0
            var count = 0

            for session in sessions {
                let checkIns = try CheckIn
                    .filter(CheckIn.Columns.sessionId == session.id!)
                    .fetchAll(db)

                for checkIn in checkIns {
                    positiveSum += checkIn.positiveComposite
                    negativeSum += checkIn.negativeComposite
                    count += 1
                }
            }

            guard count > 0 else { return nil }

            return (
                positive: positiveSum / Double(count),
                negative: negativeSum / Double(count)
            )
        }
    }

    // MARK: - Export
    func exportAllData() throws -> Data {
        let products = try getAllProducts()
        let sessions = try getAllSessions()

        var checkIns: [CheckIn] = []
        for session in sessions {
            if let sessionId = session.id {
                checkIns.append(contentsOf: try getCheckIns(forSession: sessionId))
            }
        }

        let exportData = ExportData(
            products: products,
            sessions: sessions,
            checkIns: checkIns,
            exportedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(exportData)
    }
}

// MARK: - Export Data Structure
struct ExportData: Codable {
    let products: [Product]
    let sessions: [Session]
    let checkIns: [CheckIn]
    let exportedAt: Date
}
