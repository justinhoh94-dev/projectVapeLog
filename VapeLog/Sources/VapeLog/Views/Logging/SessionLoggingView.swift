import SwiftUI

/// Session logging screen with ML-powered label scanning
struct SessionLoggingView: View {
    @State private var showScanner = false
    @State private var selectedProduct: Product?

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    scannerSection
                    manualEntrySection
                }
                .padding(24)
            }
        }
        .navigationTitle("Log Session")
        .sheet(isPresented: $showScanner) {
            LabelScannerView(scannedProduct: $selectedProduct)
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 0.10, green: 0.24, blue: 0.20),
                    Color(red: 0.04, green: 0.09, blue: 0.15)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var scannerSection: some View {
        VStack(spacing: 16) {
            Text("Scan a Label")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                showScanner = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    Text("Use Camera to Scan")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            }

            Text("Automatically extract cannabinoid and terpene data from product labels")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }

    private var manualEntrySection: some View {
        VStack(spacing: 16) {
            Text("Or Enter Manually")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                // TODO: Navigate to manual entry form
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                    Text("Manual Entry")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    NavigationStack {
        SessionLoggingView()
    }
}
