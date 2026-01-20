import Foundation

/// Reference data for terpene education
struct Terpene: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let aroma: String
    let description: String
    let effects: [String]
    let icon: String

    static let allTerpenes: [Terpene] = [
        Terpene(
            name: "Myrcene",
            aroma: "Earthy, musky, herbal",
            description: "The most common terpene in cannabis, myrcene is known for its sedating and relaxing effects. It's also found in mangoes, lemongrass, and hops.",
            effects: ["Relaxing", "Sedating", "Pain Relief", "Anti-inflammatory"],
            icon: "leaf.circle.fill"
        ),
        Terpene(
            name: "Limonene",
            aroma: "Citrus, lemon, orange",
            description: "A mood-elevating terpene with a bright citrus aroma. Limonene is known for its stress-relieving and uplifting properties.",
            effects: ["Uplifting", "Stress Relief", "Mood Enhancement", "Anti-anxiety"],
            icon: "sun.max.fill"
        ),
        Terpene(
            name: "Pinene",
            aroma: "Pine, fresh, earthy",
            description: "Found in pine needles and rosemary, pinene is associated with alertness and memory retention. It has a fresh, forest-like aroma.",
            effects: ["Alertness", "Memory", "Focus", "Anti-inflammatory"],
            icon: "tree.fill"
        ),
        Terpene(
            name: "Caryophyllene",
            aroma: "Spicy, peppery, woody",
            description: "Unique among terpenes, caryophyllene can bind to CB2 receptors, providing anti-inflammatory effects without psychoactivity.",
            effects: ["Anti-inflammatory", "Pain Relief", "Stress Relief", "Neuroprotective"],
            icon: "sparkles"
        ),
        Terpene(
            name: "Humulene",
            aroma: "Earthy, woody, hoppy",
            description: "Found in hops and coriander, humulene is known for its appetite-suppressing and anti-inflammatory properties.",
            effects: ["Appetite Suppressant", "Anti-inflammatory", "Antibacterial"],
            icon: "drop.fill"
        ),
        Terpene(
            name: "Linalool",
            aroma: "Floral, lavender, sweet",
            description: "With a floral lavender scent, linalool is prized for its calming and anti-anxiety effects. It's also found in lavender and mint.",
            effects: ["Calming", "Anti-anxiety", "Sedating", "Pain Relief"],
            icon: "cloud.fill"
        ),
        Terpene(
            name: "Terpinolene",
            aroma: "Fresh, herbal, piney",
            description: "A complex terpene with a fresh, herbaceous aroma. Despite being found in energizing strains, it has some sedating properties.",
            effects: ["Uplifting", "Antioxidant", "Antibacterial", "Sedating"],
            icon: "wind"
        ),
        Terpene(
            name: "Ocimene",
            aroma: "Sweet, herbal, woody",
            description: "A lesser-known terpene with a sweet, herbaceous aroma. Ocimene has anti-inflammatory and antifungal properties.",
            effects: ["Anti-inflammatory", "Antifungal", "Decongestant", "Antibacterial"],
            icon: "aqi.medium"
        )
    ]

    static func findByName(_ name: String) -> Terpene? {
        allTerpenes.first { $0.name.lowercased() == name.lowercased() }
    }
}
