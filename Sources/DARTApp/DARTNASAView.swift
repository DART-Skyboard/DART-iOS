import SwiftUI
import Combine

// MARK: — NASA APOD View
struct DARTNASAView: View {
    @StateObject private var manager = NASANetworkManager()
    @State private var showDatePicker = false
    private let accent = Color(red:0.0, green:0.85, blue:1.0)

    var body: some View {
        ScrollView {
            VStack(spacing:16) {

                // Header bar
                DARTCard {
                    HStack(spacing:12) {
                        Image("nasa_logo")
                            .resizable().scaledToFit().frame(height:36)
                        VStack(alignment:.leading, spacing:2) {
                            Text("ASTRONOMY PICTURE")
                                .font(.system(size:8, weight:.semibold, design:.monospaced))
                                .foregroundColor(accent.opacity(0.7))
                                .tracking(2)
                            Text("of the Day")
                                .font(.custom("Orbitron-Bold", size:13))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button { showDatePicker.toggle() } label: {
                            Image(systemName:"calendar")
                                .font(.system(size:16))
                                .foregroundColor(accent)
                                .frame(width:36, height:36)
                                .background(accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius:8))
                        }
                        .popover(isPresented:$showDatePicker) {
                            DARTDatePickerView(manager:manager)
                        }
                    }
                }

                // Image
                if let image = manager.image {
                    DARTCard {
                        VStack(alignment:.leading, spacing:10) {
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius:8))

                            if !manager.photoInfo.date.isEmpty {
                                Text(manager.photoInfo.date)
                                    .font(.system(size:9, design:.monospaced))
                                    .foregroundColor(accent.opacity(0.6))
                            }
                            if !manager.photoInfo.title.isEmpty {
                                Text(manager.photoInfo.title)
                                    .font(.custom("Orbitron-Bold", size:13))
                                    .foregroundColor(.white)
                            }
                            if let copy = manager.photoInfo.copyright {
                                Text("© \(copy)")
                                    .font(.system(size:8, design:.monospaced))
                                    .foregroundColor(.white.opacity(0.25))
                            }
                        }
                    }
                } else {
                    DARTCard {
                        VStack(spacing:14) {
                            ProgressView().tint(accent).scaleEffect(1.2)
                            Text("Loading today's image...")
                                .font(.system(size:10, design:.monospaced))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .frame(maxWidth:.infinity).padding(.vertical, 30)
                    }
                }

                // Description
                if !manager.photoInfo.description.isEmpty {
                    DARTCard {
                        VStack(alignment:.leading, spacing:8) {
                            Text("DESCRIPTION")
                                .font(.system(size:8, weight:.semibold, design:.monospaced))
                                .foregroundColor(accent.opacity(0.6))
                                .tracking(2)
                            Text(manager.photoInfo.description)
                                .font(.system(size:11))
                                .foregroundColor(.white.opacity(0.75))
                                .lineSpacing(4)
                        }
                    }
                }
            }
            .padding(14)
        }
    }
}

// MARK: — Date picker sheet
struct DARTDatePickerView: View {
    @ObservedObject var manager: NASANetworkManager
    @State private var date = Date()
    @Environment(\.dismiss) var dismiss
    private let accent = Color(red:0.0, green:0.85, blue:1.0)

    var body: some View {
        VStack(spacing:16) {
            Text("SELECT DATE")
                .font(.system(size:10, weight:.semibold, design:.monospaced))
                .foregroundColor(accent).tracking(2)
                .padding(.top, 20)
            DatePicker("", selection:$date, in: ...Date(),
                       displayedComponents:[.date])
                .labelsHidden()
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
            Button {
                manager.date = date
                dismiss()
            } label: {
                Text("Load Image")
                    .font(.system(size:13, weight:.semibold, design:.monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth:.infinity).frame(height:44)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius:10))
            }
            .padding(.horizontal, 20).padding(.bottom, 20)
        }
        .background(Color(red:0.06,green:0.08,blue:0.14))
    }
}

// MARK: — Links / Explore tab
struct DARTLinksView: View {
    private let accent = Color(red:0.0, green:0.85, blue:1.0)

    private let links: [(String, String, String, String)] = [
        ("Eyes on Exoplanets", "Explore NASA's interactive 3D exoplanet catalog",
         "globe.americas.fill", "https://eyes.nasa.gov/apps/exo/"),
        ("La Silla Observatory", "ESO\'s premier optical observatory in Chile",
         "mountain.2.fill", "https://www.eso.org/sci/facilities/lasilla.html"),
        ("DART Meadow", "Radical Deepscale — LEATR · BRPN · mc³",
         "bird.fill", "https://www.dartmeadow.com"),
        ("Artemis Program", "NASA\'s return to the Moon",
         "moonphase.new.moon", "https://www.nasa.gov/specials/artemis/"),
        ("NASA APOD Archive", "Every Astronomy Picture of the Day since 1995",
         "photo.stack", "https://apod.nasa.gov/apod/archivepix.html"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing:10) {
                DARTCard {
                    VStack(alignment:.leading, spacing:4) {
                        Text("EXPLORE")
                            .font(.system(size:8, weight:.semibold, design:.monospaced))
                            .foregroundColor(accent.opacity(0.7)).tracking(2)
                        Text("Space, Science & DART")
                            .font(.custom("Orbitron-Bold", size:14))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth:.infinity, alignment:.leading)
                }

                ForEach(links, id:\.0) { title, subtitle, icon, urlStr in
                    Button {
                        // Present SFSafariViewController directly via UIKit —
                        // bypasses SwiftUI sheet entirely, no cold-start blank screen
                        guard let url = URL(string: urlStr) else { return }
                        let vc = SFSafariViewController(url: url)
                        vc.preferredControlTintColor = UIColor(red:0, green:0.85, blue:1, alpha:1)
                        vc.preferredBarTintColor     = UIColor(red:0.04, green:0.06, blue:0.12, alpha:1)
                        vc.modalPresentationStyle    = .pageSheet
                        // Find the topmost view controller and present on it
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let root  = scene.windows.first?.rootViewController {
                            var top = root
                            while let presented = top.presentedViewController { top = presented }
                            top.present(vc, animated: true)
                        }
                    } label: {
                        DARTCard {
                            HStack(spacing:14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius:10)
                                        .fill(accent.opacity(0.1))
                                        .frame(width:44, height:44)
                                    Image(systemName:icon)
                                        .font(.system(size:18))
                                        .foregroundColor(accent)
                                }
                                VStack(alignment:.leading, spacing:3) {
                                    Text(title)
                                        .font(.system(size:12, weight:.semibold, design:.monospaced))
                                        .foregroundColor(.white)
                                    Text(subtitle)
                                        .font(.system(size:9, design:.monospaced))
                                        .foregroundColor(.white.opacity(0.4))
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName:"arrow.up.right")
                                    .font(.system(size:11))
                                    .foregroundColor(accent.opacity(0.5))
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
    }
}

// MARK: — Shared card container
struct DARTCard<Content:View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(14)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius:12))
            .overlay(RoundedRectangle(cornerRadius:12)
                .stroke(Color(red:0.0,green:0.7,blue:1.0).opacity(0.1), lineWidth:0.7))
    }
}

// MARK: — NASA Network Manager (self-contained, no AutumnServices dep)
class NASANetworkManager: ObservableObject {
    @Published var date: Date = Date()
    @Published var photoInfo = NASAPhotoInfo()
    @Published var image: Image?
    private var subscriptions = Set<AnyCancellable>()

    init() {
        $date.removeDuplicates()
            .sink { _ in self.image = nil }
            .store(in:&subscriptions)

        $date.removeDuplicates()
            .map { self.buildURL(for:$0) }
            .flatMap { url in
                URLSession.shared.dataTaskPublisher(for:url)
                    .map(\.data)
                    .decode(type:NASAPhotoInfo.self, decoder:JSONDecoder())
                    .catch { _ in Just(NASAPhotoInfo()) }
            }
            .receive(on:RunLoop.main)
            .assign(to:\.photoInfo, on:self)
            .store(in:&subscriptions)

        $photoInfo
            .compactMap(\.url)
            .flatMap { url in
                URLSession.shared.dataTaskPublisher(for:url)
                    .map(\.data).catch { _ in Just(Data()) }
            }
            .map { data -> Image? in
                guard let ui = UIImage(data:data) else { return nil }
                return Image(uiImage:ui)
            }
            .receive(on:RunLoop.main)
            .assign(to:\.image, on:self)
            .store(in:&subscriptions)
    }

    private func buildURL(for date:Date) -> URL {
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        var comps = URLComponents(string:"https://api.nasa.gov/planetary/apod")!
        comps.queryItems = [
            URLQueryItem(name:"api_key", value:"iclydG9U48D4PkGpaxb1f5bYKggvnIofqNsDv0bj"),
            URLQueryItem(name:"date",    value:fmt.string(from:date))
        ]
        return comps.url!
    }
}

struct NASAPhotoInfo: Codable {
    var title: String = ""
    var description: String = ""
    var url: URL? = nil
    var copyright: String? = nil
    var date: String = ""
    enum CodingKeys: String, CodingKey {
        case title, url, copyright, date
        case description = "explanation"
    }
}

import SafariServices
import Combine
