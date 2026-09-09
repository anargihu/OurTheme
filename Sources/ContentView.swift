import SwiftUI
import PhotosUI

struct ThemeIcon: Identifiable, Codable {
    var id = UUID()
    var appName: String
    var symbol: String
}

struct ThemeData: Codable {
    var name: String
    var iconStyle: String
    var icons: [ThemeIcon]
}

struct ContentView: View {
    @State private var theme = ThemeData(
        name: "My Theme",
        iconStyle: "Rounded",
        icons: [
            ThemeIcon(appName: "Safari", symbol: "safari"),
            ThemeIcon(appName: "Music", symbol: "music.note"),
            ThemeIcon(appName: "Messages", symbol: "message.fill"),
            ThemeIcon(appName: "Camera", symbol: "camera.fill")
        ]
    )
    @State private var showingEditor = false
    @State private var showingCreate = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.18), .purple.opacity(0.14), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("OurTheme")
                                    .font(.largeTitle.bold())
                                Text("Create your own iPhone theme.")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                showingCreate = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.headline)
                                    .padding(12)
                                    .background(.thinMaterial, in: Circle())
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("My Theme")
                                .font(.title2.bold())

                            HomeScreenPreview(theme: theme)
                                .frame(maxWidth: .infinity)

                            Button {
                                showingEditor = true
                            } label: {
                                Label("Edit Theme", systemImage: "slider.horizontal.3")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }

                        Text("Icons")
                            .font(.title2.bold())

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                            ForEach(theme.icons) { icon in
                                VStack(spacing: 7) {
                                    Image(systemName: icon.symbol)
                                        .font(.title2)
                                        .frame(width: 58, height: 58)
                                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    Text(icon.appName)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingEditor) {
                ThemeEditor(theme: $theme)
            }
            .sheet(isPresented: $showingCreate) {
                CreateThemeView(theme: $theme)
            }
        }
    }
}

struct HomeScreenPreview: View {
    let theme: ThemeData

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("9:41")
                    .font(.headline)
                Spacer()
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }

            Spacer(minLength: 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 22) {
                ForEach(theme.icons) { icon in
                    VStack(spacing: 5) {
                        Image(systemName: icon.symbol)
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        Text(icon.appName)
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
            }

            Spacer(minLength: 8)
        }
        .padding(18)
        .frame(height: 430)
        .background(
            LinearGradient(
                colors: [.indigo.opacity(0.7), .purple.opacity(0.55), .blue.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 34)
        )
        .clipShape(RoundedRectangle(cornerRadius: 34))
    }
}

struct CreateThemeView: View {
    @Binding var theme: ThemeData
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Theme") {
                    TextField("Theme name", text: $theme.name)
                }

                Section("Icon Style") {
                    Picker("Style", selection: $theme.iconStyle) {
                        Text("Original").tag("Original")
                        Text("Rounded").tag("Rounded")
                        Text("Minimal").tag("Minimal")
                        Text("Custom").tag("Custom")
                    }
                }
            }
            .navigationTitle("New Theme")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemeEditor: View {
    @Binding var theme: ThemeData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIcon: ThemeIcon?
    @State private var showingAddIcon = false

    var body: some View {
        NavigationStack {
            List {
                Section("Theme") {
                    TextField("Theme name", text: $theme.name)

                    Picker("Icon Style", selection: $theme.iconStyle) {
                        Text("Original").tag("Original")
                        Text("Rounded").tag("Rounded")
                        Text("Minimal").tag("Minimal")
                        Text("Custom").tag("Custom")
                    }
                }

                Section("Apps") {
                    ForEach(theme.icons) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            HStack {
                                Image(systemName: icon.symbol)
                                    .frame(width: 36, height: 36)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                Text(icon.appName)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        theme.icons.remove(atOffsets: offsets)
                    }

                    Button {
                        showingAddIcon = true
                    } label: {
                        Label("Add App", systemImage: "plus")
                    }
                }

                Section("Export") {
                    ShareLink(item: exportData()) {
                        Label("Export OurTheme", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Icon Editor")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedIcon) { icon in
                IconEditor(icon: icon) { updated in
                    if let index = theme.icons.firstIndex(where: { $0.id == updated.id }) {
                        theme.icons[index] = updated
                    }
                    selectedIcon = nil
                }
            }
            .sheet(isPresented: $showingAddIcon) {
                AddIconView { icon in
                    theme.icons.append(icon)
                    showingAddIcon = false
                }
            }
        }
    }

    private func exportData() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return (try? encoder.encode(theme)) ?? Data()
    }
}

struct AddIconView: View {
    let onAdd: (ThemeIcon) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var appName = ""
    @State private var symbol = "app.fill"

    var body: some View {
        NavigationStack {
            Form {
                TextField("App name", text: $appName)
                TextField("SF Symbol", text: $symbol)

                Button("Add") {
                    guard !appName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onAdd(ThemeIcon(appName: appName, symbol: symbol))
                    dismiss()
                }
            }
            .navigationTitle("Add App")
        }
    }
}

struct IconEditor: View {
    @State private var icon: ThemeIcon
    let onSave: (ThemeIcon) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var importedImage: Image?

    init(icon: ThemeIcon, onSave: @escaping (ThemeIcon) -> Void) {
        _icon = State(initialValue: icon)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Preview") {
                    VStack {
                        if let importedImage {
                            importedImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                        } else {
                            Image(systemName: icon.symbol)
                                .font(.system(size: 48))
                                .frame(width: 100, height: 100)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 25))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section("App") {
                    TextField("App name", text: $icon.appName)
                    TextField("SF Symbol", text: $icon.symbol)
                }

                Section("Custom Image") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose From Photos", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            guard let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                                  let uiImage = UIImage(data: data) else { return }
                            importedImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
            .navigationTitle("Edit Icon")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(icon)
                        dismiss()
                    }
                }
            }
        }
    }
}
