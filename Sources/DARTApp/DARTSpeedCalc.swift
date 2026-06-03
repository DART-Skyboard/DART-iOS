import SwiftUI

// MARK: — DART Speed Calculator
// DART = mc³  |  1 DART Year = 188,172 Light Years
struct DARTSpeedCalcView: View {
    @State private var lyInput: String = ""
    @State private var dartYears: Double = 0
    @FocusState private var inputFocused: Bool

    // Arc Edge geometry states
    @State private var radicalSize: Double = 0
    @State private var showGeometry = false

    private let dartYear: Double = 188172 // light years per DART year
    private let accent = Color(red:0.0, green:0.85, blue:1.0)

    var dartResult: Double {
        guard let ly = Double(lyInput), ly > 0 else { return 0 }
        return ly / dartYear
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── Hero formula card ──────────────────────────────
                DARTCard {
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            formulaChip("d", color: .cyan)
                            Text(" = ").font(.system(size:18, weight:.bold, design:.monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            formulaChip("mc³", color: accent)
                        }
                        Text("1 DART Year = 188,172 Light Years")
                            .font(.system(size:11, design:.monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        Text("Speed of Light cubed × seconds/year")
                            .font(.system(size:9, design:.monospaced))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .frame(maxWidth:.infinity)
                    .padding(.vertical, 6)
                }

                // ── Input ──────────────────────────────────────────
                DARTCard {
                    VStack(alignment:.leading, spacing:10) {
                        Text("LIGHT YEARS")
                            .font(.system(size:8, weight:.semibold, design:.monospaced))
                            .foregroundColor(accent.opacity(0.7))
                            .tracking(2)

                        HStack(spacing:10) {
                            TextField("Enter distance...", text: $lyInput)
                                .font(.system(size:20, weight:.bold, design:.monospaced))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .focused($inputFocused)
                                .onChange(of: lyInput) { _ in
                                    if let v = Double(lyInput) { radicalSize = v }
                                }

                            if !lyInput.isEmpty {
                                Button { lyInput = ""; inputFocused = false } label: {
                                    Image(systemName:"xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius:10))
                        .overlay(RoundedRectangle(cornerRadius:10)
                            .stroke(inputFocused ? accent.opacity(0.5) : Color.white.opacity(0.08), lineWidth:1))

                        // Quick presets
                        ScrollView(.horizontal, showsIndicators:false) {
                            HStack(spacing:6) {
                                ForEach([
                                    ("Alpha Centauri","4.37"),
                                    ("Andromeda","2537000"),
                                    ("Stephenson 2-18","19570"),
                                    ("Observable Universe","46500000000"),
                                ], id:\.0) { label, val in
                                    Button { lyInput = val; inputFocused = false } label: {
                                        Text(label)
                                            .font(.system(size:9, design:.monospaced))
                                            .foregroundColor(accent.opacity(0.8))
                                            .padding(.horizontal,10).padding(.vertical,5)
                                            .background(accent.opacity(0.07))
                                            .clipShape(Capsule())
                                            .overlay(Capsule()
                                                .stroke(accent.opacity(0.2), lineWidth:0.7))
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Result ─────────────────────────────────────────
                if dartResult > 0 {
                    DARTCard {
                        VStack(spacing:12) {
                            Text("DART TRAVEL TIME")
                                .font(.system(size:8, weight:.semibold, design:.monospaced))
                                .foregroundColor(accent.opacity(0.7))
                                .tracking(2)
                                .frame(maxWidth:.infinity, alignment:.leading)

                            // Main result
                            HStack(alignment:.firstTextBaseline, spacing:6) {
                                Text(formatDartYears(dartResult))
                                    .font(.system(size:28, weight:.bold, design:.monospaced))
                                    .foregroundColor(accent)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                Text("DART Years")
                                    .font(.system(size:12, design:.monospaced))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(maxWidth:.infinity, alignment:.leading)

                            Divider().background(accent.opacity(0.15))

                            // Sub-units breakdown
                            VStack(spacing:6) {
                                dartTimeRow("0.1 DART Year",  dartResult * 0.1,   "= 36.5 days")
                                dartTimeRow("0.01 DART Year", dartResult * 0.01,  "= 3.65 days")
                                dartTimeRow("0.001",          dartResult * 0.001, "= 31.97 hrs")
                                dartTimeRow("0.0001",         dartResult * 0.0001,"= 70.02 min")
                            }

                            Divider().background(accent.opacity(0.15))

                            Text("Based on c = 186,282 mi/s × 31,536,000 s/yr, cubed")
                                .font(.system(size:8, design:.monospaced))
                                .foregroundColor(.white.opacity(0.2))
                                .multilineTextAlignment(.center)
                        }
                    }

                    // ── Arc Edge geometry ──────────────────────────
                    DARTCard {
                        VStack(spacing:10) {
                            HStack {
                                Text("ARC EDGE GEOMETRY")
                                    .font(.system(size:8, weight:.semibold, design:.monospaced))
                                    .foregroundColor(Color.purple.opacity(0.8))
                                    .tracking(2)
                                Spacer()
                                Text("DOC = 3.0")
                                    .font(.system(size:8, design:.monospaced))
                                    .foregroundColor(.white.opacity(0.25))
                            }

                            let d = radicalSize
                            arcGeoRow("Diameter  √(r×3)²",      pow(sqrt(d * 3), 2))
                            arcGeoRow("Circumf.  √(r×3)⁴",      pow(pow(sqrt(d * 3), 2), 2))
                            arcGeoRow("Area      √(r×3)⁶",      pow(pow(sqrt(d * 3), 2), 3))
                            arcGeoRow("Volume    √(r×3)^12",     pow(pow(pow(sqrt(d * 3), 2), 3), 2))
                        }
                    }
                }
            }
            .padding(14)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func formulaChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size:22, weight:.black, design:.monospaced))
            .foregroundColor(color)
            .padding(.horizontal,10).padding(.vertical,4)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius:6))
    }

    private func dartTimeRow(_ label: String, _ val: Double, _ note: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size:9, design:.monospaced))
                .foregroundColor(.white.opacity(0.35))
                .frame(width:100, alignment:.leading)
            Text(formatDartYears(val))
                .font(.system(size:9, weight:.semibold, design:.monospaced))
                .foregroundColor(accent.opacity(0.8))
            Spacer()
            Text(note)
                .font(.system(size:8, design:.monospaced))
                .foregroundColor(.white.opacity(0.2))
        }
    }

    private func arcGeoRow(_ label: String, _ val: Double) -> some View {
        HStack {
            Text(label)
                .font(.system(size:9, design:.monospaced))
                .foregroundColor(.white.opacity(0.35))
            Spacer()
            Text(formatSci(val))
                .font(.system(size:9, weight:.semibold, design:.monospaced))
                .foregroundColor(Color.purple.opacity(0.8))
        }
    }

    private func formatDartYears(_ v: Double) -> String {
        if v == 0 { return "0" }
        if v >= 1e9 { return String(format:"%.4e", v) }
        if v >= 1000 { return String(format:"%.2f", v) }
        if v >= 1 { return String(format:"%.6f", v) }
        return String(format:"%.8f", v)
    }

    private func formatSci(_ v: Double) -> String {
        if v == 0 || v.isNaN || v.isInfinite { return "—" }
        if v >= 1e6 || v < 0.001 { return String(format:"%.3e", v) }
        return String(format:"%.4f", v)
    }
}
