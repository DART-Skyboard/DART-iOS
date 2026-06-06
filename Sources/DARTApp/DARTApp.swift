import SwiftUI

@main
struct DARTApp: App {
    var body: some Scene {
        WindowGroup {
            DARTContentView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: — Root
struct DARTContentView: View {
    @State private var selectedTab: DARTSection = .speed
    
    var body: some View {
        ZStack {
            DARTSpaceBackground().ignoresSafeArea()
            VStack(spacing: 0) {
                DARTTopChrome()
                TabView(selection: $selectedTab) {
                    DARTSpeedCalcView().tag(DARTSection.speed)
                    DARTNASAView().tag(DARTSection.nasa)
                    DARTLinksView().tag(DARTSection.links)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                DARTTabBar(selected: $selectedTab)
            }
        }
    }
}

enum DARTSection: Int {
    case speed, nasa, links
}

// MARK: — Animated space background
struct DARTSpaceBackground: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        ZStack {
            Color(red:0.01, green:0.015, blue:0.04)
            // Nebula glow — top
            RadialGradient(
                colors: [Color(red:0.0,green:0.56,blue:0.82).opacity(0.18), .clear],
                center: UnitPoint(x:0.5, y:0.05), startRadius:0, endRadius:320)
            // Nebula glow — bottom right
            RadialGradient(
                colors: [Color(red:0.3,green:0.1,blue:0.7).opacity(0.12), .clear],
                center: UnitPoint(x:0.85, y:0.9), startRadius:0, endRadius:240)
        }
    }
}

// MARK: — Top chrome
struct DARTTopChrome: View {
    var body: some View {
        HStack(spacing: 8) {
            // Hummingbird mark
            Image(systemName: "bird.fill")
                .font(.system(size: 14))
                .foregroundStyle(LinearGradient(
                    colors: [Color(red:0.2,green:0.85,blue:0.7),
                             Color(red:0.0,green:0.6,blue:1.0)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
            Text("DART")
                .font(.custom("Orbitron-Bold", size: 18))
                .foregroundColor(.white)
                .tracking(5)
            Text("Equation")
                .font(.custom("Orbitron-Bold", size: 11))
                .foregroundColor(Color(red:0.0,green:0.85,blue:1.0).opacity(0.7))
                .tracking(3)
                .padding(.leading, 1)
            Text("= mc³")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(red:0.0,green:0.85,blue:1.0).opacity(0.5))
                .padding(.leading, 1)
            Spacer()
            // Live date
            Text(Date(), format: .dateTime.month(.abbreviated).day().year())
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height:0.5)
            .foregroundColor(Color(red:0.0,green:0.7,blue:1.0).opacity(0.25)),
            alignment:.bottom)
    }
}

// MARK: — Tab bar
struct DARTTabBar: View {
    @Binding var selected: DARTSection
    private let tabs: [(DARTSection, String, String)] = [
        (.speed, "Equation",   "function"),
        (.nasa,  "APOD",       "moonphase.full.moon.inverse"),
        (.links, "Explore",    "safari"),
    ]
    var body: some View {
        HStack(spacing:0) {
            ForEach(tabs, id:\.0.rawValue) { tab, label, icon in
                Button { withAnimation(.spring(response:0.3)) { selected = tab } } label: {
                    VStack(spacing:3) {
                        Image(systemName: icon)
                            .font(.system(size: selected == tab ? 20 : 17))
                            .foregroundColor(selected == tab
                                ? Color(red:0.0,green:0.85,blue:1.0)
                                : .white.opacity(0.3))
                        Text(label)
                            .font(.system(size:9, design:.monospaced))
                            .foregroundColor(selected == tab
                                ? Color(red:0.0,green:0.85,blue:1.0)
                                : .white.opacity(0.25))
                    }
                    .frame(maxWidth:.infinity).padding(.vertical,10)
                    .background(selected == tab
                        ? Color(red:0.0,green:0.85,blue:1.0).opacity(0.07)
                        : .clear)
                    .overlay(Rectangle().frame(height:1.5)
                        .foregroundColor(selected == tab
                            ? Color(red:0.0,green:0.85,blue:1.0)
                            : .clear), alignment:.top)
                }
            }
        }
        .background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height:0.5)
            .foregroundColor(.white.opacity(0.08)), alignment:.top)
    }
}
