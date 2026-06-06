
import SwiftUI

// MARK: — DART Equation Calculator
// E = mc³  |  DART velocity = c³ (speed of light cubed, effective)
// Travel time = distance / c³
// Output in smart units: ns, µs, ms, s, min, hr, days

// Physical constants
private let C_MS: Double = 299_792_458        // speed of light m/s
private let C_CUBED: Double = 2.694376424e25  // c³ m/s (effective DART velocity)
private let LY_METERS: Double = 9.460730473e15 // meters per light year

struct DARTSpeedCalcView: View {
    @State private var lyInput: String = ""
    @FocusState private var inputFocused: Bool

    private let accent = Color(red:0.0, green:0.85, blue:1.0)
    private let gold   = Color(red:1.0, green:0.82, blue:0.2)

    // ── Presets ────────────────────────────────────────────────────
    private let presets: [(name: String, ly: String, subtitle: String)] = [
        ("α Cen",  "4.37",         "Alpha Centauri · 4.37 ly"),
        ("Milky Way", "105700",    "Milky Way diameter · 105,700 ly"),
        ("Andromeda", "2537000",   "Andromeda Galaxy · 2.537M ly"),
        ("Obs. Universe", "46500000000", "Observable Universe · 46.5B ly"),
    ]

    // ── Computed travel time in seconds ───────────────────────────
    var travelSeconds: Double? {
        guard let ly = Double(lyInput), ly > 0 else { return nil }
        let meters = ly * LY_METERS
        return meters / C_CUBED
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── Formula hero ───────────────────────────────────
                DARTCard {
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            formulaChip("E", color: .white.opacity(0.6))
                            Text(" = ").mono(18).fgr(.white.opacity(0.4))
                            formulaChip("m", color: .white.opacity(0.6))
                            formulaChip("c³", color: accent)
                        }
                        Text("DART velocity = c³  ·  \(formatSci(C_CUBED)) m/s")
                            .mono(9).fgr(.white.opacity(0.3))
                        Text("distance ÷ c³  →  DART travel time")
                            .mono(9).fgr(accent.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }

                // ── Input ──────────────────────────────────────────
                DARTCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DISTANCE IN LIGHT YEARS")
                            .mono(8).fgr(accent.opacity(0.7)).tracking(2)

                        HStack(spacing: 10) {
                            TextField("Enter light years...", text: $lyInput)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .focused($inputFocused)
                            if !lyInput.isEmpty {
                                Button { lyInput = ""; inputFocused = false } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(inputFocused
                                    ? accent.opacity(0.5)
                                    : Color.white.opacity(0.08), lineWidth: 1))

                        // Presets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(presets, id: \.name) { preset in
                                    Button {
                                        lyInput = preset.ly
                                        inputFocused = false
                                    } label: {
                                        VStack(spacing: 2) {
                                            Text(preset.name)
                                                .mono(9).fgr(accent.opacity(0.9))
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(accent.opacity(0.08))
                                        .clipShape(Capsule())
                                        .overlay(Capsule()
                                            .stroke(accent.opacity(0.25), lineWidth: 0.7))
                                    }
                                }
                            }
                        }

                        // Show what preset this matches
                        if let p = presets.first(where: { $0.ly == lyInput }) {
                            Text(p.subtitle)
                                .mono(9).fgr(.white.opacity(0.35))
                                .padding(.top, 2)
                        }
                    }
                }

                // ── Result ─────────────────────────────────────────
                if let t = travelSeconds {
                    DARTCard {
                        VStack(spacing: 14) {
                            HStack {
                                Text("DART TRAVEL TIME")
                                    .mono(8).fgr(accent.opacity(0.7)).tracking(2)
                                Spacer()
                                Text("E = mc³")
                                    .mono(8).fgr(.white.opacity(0.2))
                            }

                            // Big primary result
                            let primary = primaryUnit(t)
                            VStack(spacing: 4) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(primary.value)
                                        .font(.system(size: 36, weight: .black,
                                                      design: .monospaced))
                                        .foregroundColor(accent)
                                        .minimumScaleFactor(0.4)
                                        .lineLimit(1)
                                    Text(primary.unit)
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.bottom, 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                if let sub = primary.subtext {
                                    Text(sub)
                                        .mono(9).fgr(.white.opacity(0.3))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }

                            Divider().background(accent.opacity(0.12))

                            // Full breakdown in all units
                            VStack(spacing: 7) {
                                timeRow("nanoseconds",  t * 1e9)
                                timeRow("microseconds", t * 1e6)
                                timeRow("milliseconds", t * 1e3)
                                timeRow("seconds",      t)
                                timeRow("minutes",      t / 60)
                                timeRow("hours",        t / 3600)
                                if t / 86400 >= 0.001 {
                                    timeRow("days",     t / 86400)
                                }
                            }

                            Divider().background(accent.opacity(0.12))

                            // Input summary
                            if let ly = Double(lyInput) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Distance")
                                            .mono(8).fgr(.white.opacity(0.3))
                                        Text("\(formatLY(ly)) light years")
                                            .mono(10).fgr(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 3) {
                                        Text("At c³ velocity")
                                            .mono(8).fgr(.white.opacity(0.3))
                                        Text(formatSci(C_CUBED) + " m/s")
                                            .mono(10).fgr(accent.opacity(0.5))
                                    }
                                }
                            }
                        }
                    }

                    // ── Arc Edge geometry ──────────────────────────
                    if let ly = Double(lyInput) {
                        DARTCard {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("ARC EDGE GEOMETRY")
                                        .mono(8).fgr(Color.purple.opacity(0.8)).tracking(2)
                                    Spacer()
                                    Text("DOC = 3.0")
                                        .mono(8).fgr(.white.opacity(0.2))
                                }
                                let d = ly
                                arcRow("√(d×3)²  Diameter", pow(sqrt(d * 3), 2))
                                arcRow("√(d×3)⁴  Circumf.", pow(pow(sqrt(d * 3), 2), 2))
                                arcRow("√(d×3)⁶  Area",     pow(pow(sqrt(d * 3), 2), 3))
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // ── Helpers ────────────────────────────────────────────────────

    /// Returns the most human-readable unit for a time in seconds
    private func primaryUnit(_ s: Double) -> (value: String, unit: String, subtext: String?) {
        if s < 1e-6 {
            return (String(format: "%.4f", s * 1e9), "nanoseconds",
                    String(format: "%.6f µs", s * 1e6))
        } else if s < 1e-3 {
            return (String(format: "%.4f", s * 1e6), "microseconds",
                    String(format: "%.4f ms", s * 1e3))
        } else if s < 1 {
            return (String(format: "%.4f", s * 1e3), "milliseconds",
                    String(format: "%.6f s", s))
        } else if s < 60 {
            return (String(format: "%.4f", s), "seconds",
                    String(format: "%.4f ms", s * 1e3))
        } else if s < 3600 {
            return (String(format: "%.4f", s / 60), "minutes",
                    String(format: "%.2f s", s))
        } else if s < 86400 {
            return (String(format: "%.4f", s / 3600), "hours",
                    String(format: "%.2f min", s / 60))
        } else {
            return (String(format: "%.4f", s / 86400), "days",
                    String(format: "%.2f hr", s / 3600))
        }
    }

    private func timeRow(_ unit: String, _ val: Double) -> some View {
        HStack {
            Text(unit)
                .mono(9).fgr(.white.opacity(0.3))
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(formatTimeVal(val))
                .mono(9).fgr(val >= 0.001 ? accent.opacity(0.85) : .white.opacity(0.2))
                .fontWeight(val >= 0.001 && val < 1e12 ? .semibold : .regular)
        }
    }

    private func arcRow(_ label: String, _ val: Double) -> some View {
        HStack {
            Text(label).mono(9).fgr(.white.opacity(0.3))
            Spacer()
            Text(formatSci(val)).mono(9).fgr(Color.purple.opacity(0.7))
        }
    }

    private func formulaChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .black, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func formatTimeVal(_ v: Double) -> String {
        if v == 0 { return "0" }
        if v.isNaN || v.isInfinite { return "—" }
        if v >= 1e12 { return String(format: "%.3e", v) }
        if v >= 1e6  { return String(format: "%.2f", v) }
        if v >= 1000 { return String(format: "%.4f", v) }
        if v >= 1    { return String(format: "%.6f", v) }
        if v >= 0.001 { return String(format: "%.8f", v) }
        return String(format: "%.3e", v)
    }

    private func formatSci(_ v: Double) -> String {
        if v == 0 || v.isNaN || v.isInfinite { return "—" }
        if v >= 1e6 || v < 0.0001 { return String(format: "%.4e", v) }
        return String(format: "%.6f", v)
    }

    private func formatLY(_ v: Double) -> String {
        if v >= 1e9  { return String(format: "%.3e", v) }
        if v >= 1e6  { return String(format: "%.3fM", v / 1e6) }
        if v >= 1000 { return String(format: "%.1f k", v / 1000) }
        return String(format: "%.2f", v)
    }
}

// MARK: — SwiftUI view modifier helpers (keeps body readable)
private extension Text {
    func mono(_ size: CGFloat) -> Text {
        self.font(.system(size: size, design: .monospaced))
    }
    func fgr(_ color: Color) -> Text {
        self.foregroundColor(color)
    }
}
