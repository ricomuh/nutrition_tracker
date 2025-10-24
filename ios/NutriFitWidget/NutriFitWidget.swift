import WidgetKit
import SwiftUI

struct NutriFitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NutriFitEntry {
        NutriFitEntry(date: Date(), calories: 0, targetCalories: 2000, protein: 0, carbs: 0, fat: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (NutriFitEntry) -> ()) {
        let entry = NutriFitEntry(date: Date(), calories: 0, targetCalories: 2000, protein: 0, carbs: 0, fat: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get data from UserDefaults (shared with Flutter app)
        let sharedDefaults = UserDefaults(suiteName: "group.nutrifit.ai")
        
        let calories = sharedDefaults?.integer(forKey: "calories") ?? 0
        let targetCalories = sharedDefaults?.integer(forKey: "target_calories") ?? 2000
        let protein = sharedDefaults?.integer(forKey: "protein") ?? 0
        let carbs = sharedDefaults?.integer(forKey: "carbs") ?? 0
        let fat = sharedDefaults?.integer(forKey: "fat") ?? 0
        
        let entry = NutriFitEntry(
            date: Date(),
            calories: calories,
            targetCalories: targetCalories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct NutriFitEntry: TimelineEntry {
    let date: Date
    let calories: Int
    let targetCalories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}

struct NutriFitWidgetEntryView : View {
    var entry: NutriFitWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .bold))
                
                Text("NutriFit AI")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Today")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("\(entry.calories)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("/ \(entry.targetCalories)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Cal")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("P")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                            .frame(width: 12)
                        
                        ProgressView(value: Double(entry.protein), total: 150.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 0.5, anchor: .center)
                        
                        Text("\(entry.protein)g")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("C")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 12)
                        
                        ProgressView(value: Double(entry.carbs), total: 250.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 0.5, anchor: .center)
                        
                        Text("\(entry.carbs)g")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("F")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 12)
                        
                        ProgressView(value: Double(entry.fat), total: 80.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 0.5, anchor: .center)
                        
                        Text("\(entry.fat)g")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            let remaining = entry.targetCalories - entry.calories
            Text(remaining > 0 ? "\(remaining) cal left" : remaining == 0 ? "Perfect balance!" : "\(-remaining) cal over")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct NutriFitWidget: Widget {
    let kind: String = "NutriFitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NutriFitWidgetProvider()) { entry in
            NutriFitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NutriFit Daily Summary")
        .description("Track your daily nutrition progress including calories and macros")
        .supportedFamilies([.systemMedium])
    }
}

struct NutriFitWidget_Previews: PreviewProvider {
    static var previews: some View {
        NutriFitWidgetEntryView(entry: NutriFitEntry(date: Date(), calories: 1250, targetCalories: 2000, protein: 85, carbs: 150, fat: 45))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}