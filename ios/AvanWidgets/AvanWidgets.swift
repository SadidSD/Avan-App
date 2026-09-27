import WidgetKit
import SwiftUI

struct AvanWidgetEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
    let category: String
    let streakDays: Int
    let theme: String
}

struct AvanWidgetProvider: TimelineProvider {
    let appGroupId = "group.com.avanapp.avan_app"

    func placeholder(in context: Context) -> AvanWidgetEntry {
        AvanWidgetEntry(
            date: Date(),
            quote: "I am securely rooted in this exact moment, completely capable.",
            author: "AVAN",
            category: "DAILY PRIME",
            streakDays: 12,
            theme: "Soft Beige"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AvanWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AvanWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 2 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> AvanWidgetEntry {
        let prefs = UserDefaults(suiteName: appGroupId)
        let quote = prefs?.string(forKey: "quote") ?? "I am securely rooted in this exact moment."
        let author = prefs?.string(forKey: "author") ?? "AVAN"
        let category = prefs?.string(forKey: "category") ?? "DAILY PRIME"
        let streakDays = prefs?.integer(forKey: "streakDays") ?? 0
        let theme = prefs?.string(forKey: "theme") ?? "Soft Beige"

        return AvanWidgetEntry(
            date: Date(),
            quote: quote,
            author: author,
            category: category,
            streakDays: streakDays,
            theme: theme
        )
    }
}

struct AvanWidgetEntryView: View {
    var entry: AvanWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            backgroundColor
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.category.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.33))
                    Spacer()
                    if entry.streakDays > 0 {
                        Text("🔥 \(entry.streakDays)d")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.77, green: 0.58, blue: 0.42))
                    }
                }
                Spacer()
                Text("\"\(entry.quote)\"")
                    .font(.system(size: family == .systemLarge ? 17 : 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.24, green: 0.17, blue: 0.12))
                    .lineLimit(family == .systemSmall ? 4 : 5)
                Spacer()
                Text("• \(entry.author)")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(Color(red: 0.71, green: 0.63, blue: 0.54))
            }
            .padding(14)
        }
    }

    private var backgroundColor: Color {
        if entry.theme == "Dark Espresso" {
            return Color(red: 0.15, green: 0.10, blue: 0.08)
        }
        return Color(red: 1.0, green: 0.97, blue: 0.95)
    }
}

@main
struct AvanWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AvanMainWidget()
    }
}

struct AvanMainWidget: Widget {
    let kind: String = "AvanWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AvanWidgetProvider()) { entry in
            AvanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AVAN Daily Affirmations")
        .description("Daily affirmations and mindset presence right on your screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryCircular])
    }
}
