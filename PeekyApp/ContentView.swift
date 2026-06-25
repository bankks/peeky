import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "eye.fill")
                .font(.system(size: 48))
                .foregroundStyle(.purple)

            Text("Peeky is running")
                .font(.title2.weight(.semibold))

            Text("Press **Space** on any .md file in Finder\nto preview it instantly.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.body)

            Divider()

            Text("Manage preferences in **Settings** (⌘,)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(width: 340)
    }
}

struct SettingsView: View {
    @AppStorage(AppSettings.Keys.theme, store: AppSettings.store) private var theme: String = AppSettings.Theme.system.rawValue
    @AppStorage(AppSettings.Keys.fontSize, store: AppSettings.store) private var fontSize: Double = 16
    @AppStorage(AppSettings.Keys.lineWidth, store: AppSettings.store) private var lineWidth: Double = 720

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $theme) {
                    Text("System").tag(AppSettings.Theme.system.rawValue)
                    Text("Light").tag(AppSettings.Theme.light.rawValue)
                    Text("Dark").tag(AppSettings.Theme.dark.rawValue)
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("Font size")
                    Spacer()
                    Slider(value: $fontSize, in: 12...22, step: 1)
                        .frame(width: 120)
                    Text("\(Int(fontSize))px")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }

                HStack {
                    Text("Content width")
                    Spacer()
                    Slider(value: $lineWidth, in: 480...960, step: 40)
                        .frame(width: 120)
                    Text("\(Int(lineWidth))px")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 46, alignment: .trailing)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding()
    }
}

#Preview {
    ContentView()
}
