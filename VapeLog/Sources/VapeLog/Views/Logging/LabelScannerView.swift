import SwiftUI
import AVFoundation
import Vision

/// ML-powered camera view for scanning cannabis product labels
struct LabelScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var scannedProduct: Product?
    @StateObject private var scannerViewModel = LabelScannerViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreviewView(session: scannerViewModel.captureSession)
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    scanOverlay

                    Spacer()

                    if scannerViewModel.isProcessing {
                        processingIndicator
                    } else {
                        captureButton
                    }

                    if let result = scannerViewModel.scanResult {
                        resultView(result)
                    }
                }
                .padding()
            }
            .navigationTitle("Scan Label")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            scannerViewModel.startSession()
        }
        .onDisappear {
            scannerViewModel.stopSession()
        }
    }

    private var scanOverlay: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 3)
            .frame(width: 300, height: 200)
            .overlay(
                VStack {
                    Text("Position label within frame")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                }
                .offset(y: -120)
            )
    }

    private var processingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Analyzing label...")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
    }

    private var captureButton: some View {
        Button {
            scannerViewModel.captureAndAnalyze()
        } label: {
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 4)
                        .frame(width: 80, height: 80)
                )
        }
        .padding(.bottom, 40)
    }

    private func resultView(_ result: ScanResult) -> some View {
        VStack(spacing: 12) {
            Text("Scan Complete!")
                .font(.headline)
                .foregroundColor(.white)

            if !result.cannabinoids.isEmpty {
                Text("Found: \(result.cannabinoids.map { "\($0.key): \($0.value)%" }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            Button("Use This Data") {
                // TODO: Create product from scan result
                dismiss()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.green)
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

// MARK: - Camera Preview
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Scanner ViewModel
class LabelScannerViewModel: NSObject, ObservableObject {
    @Published var isProcessing = false
    @Published var scanResult: ScanResult?

    let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()

    override init() {
        super.init()
        setupCamera()
    }

    private func setupCamera() {
        captureSession.beginConfiguration()

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func captureAndAnalyze() {
        isProcessing = true

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func analyzeImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            isProcessing = false
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // OCR text recognition
        let textRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self?.isProcessing = false
                return
            }

            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            self?.extractCannabinoidData(from: recognizedText)
        }

        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true

        do {
            try requestHandler.perform([textRequest])
        } catch {
            print("Failed to perform text recognition: \(error)")
            isProcessing = false
        }
    }

    private func extractCannabinoidData(from text: [String]) {
        var cannabinoids: [String: Double] = [:]
        var terpenes: [String: Double] = [:]

        // Simple regex patterns for cannabinoid percentages
        let patterns = [
            "THC": #"THC[:\s]*(\d+\.?\d*)%?"#,
            "CBD": #"CBD[:\s]*(\d+\.?\d*)%?"#,
            "CBG": #"CBG[:\s]*(\d+\.?\d*)%?"#,
            "THCV": #"THCV[:\s]*(\d+\.?\d*)%?"#
        ]

        let terpenePatterns = [
            "Myrcene", "Limonene", "Pinene", "Caryophyllene",
            "Humulene", "Linalool", "Terpinolene", "Ocimene"
        ]

        for line in text {
            // Extract cannabinoids
            for (name, pattern) in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let valueRange = Range(match.range(at: 1), in: line) {
                    if let value = Double(line[valueRange]) {
                        cannabinoids[name] = value
                    }
                }
            }

            // Extract terpenes
            for terpene in terpenePatterns {
                let pattern = #"\#(terpene)[:\s]*(\d+\.?\d*)%?"#
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                   let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                   let valueRange = Range(match.range(at: 1), in: line) {
                    if let value = Double(line[valueRange]) {
                        terpenes[terpene] = value
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.scanResult = ScanResult(
                cannabinoids: cannabinoids,
                terpenes: terpenes,
                rawText: text.joined(separator: "\n")
            )
            self.isProcessing = false
        }
    }
}

// MARK: - Photo Capture Delegate
extension LabelScannerViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            isProcessing = false
            return
        }

        analyzeImage(image)
    }
}

// MARK: - Scan Result
struct ScanResult {
    let cannabinoids: [String: Double]
    let terpenes: [String: Double]
    let rawText: String
}

#Preview {
    LabelScannerView(scannedProduct: .constant(nil))
}
