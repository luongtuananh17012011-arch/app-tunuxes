import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var manager: ProxyManager
    @State private var showFileImporter = false

    private let neonCyan = Color(red: 0.0, green: 0.90, blue: 1.0)
    private let neonBlue = Color(red: 0.08, green: 0.45, blue: 1.0)
    private let cardBg = Color(red: 0.06, green: 0.09, blue: 0.16)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    headerBanner
                    activationRingCard
                    fileImportCard
                    if let cfg = manager.config {
                        configDetailsCard(cfg)
                    }
                    switchesCard
                    consoleLogCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.02, green: 0.03, blue: 0.07), Color(red: 0.04, green: 0.08, blue: 0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.item, .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let firstURL = urls.first {
                        manager.importConfigFile(from: firstURL)
                    }
                case .failure(let error):
                    manager.appendLog("Huỷ hoặc lỗi chọn tệp: \(error.localizedDescription)")
                }
            }
        }
    }

    private var headerBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TUNA PROXY PRO")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(neonCyan)
                Text("iOS File Container & Tunnel Activator")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(manager.isProxyActive ? "ACTIVE" : "STANDBY")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(manager.isProxyActive ? Color.green.opacity(0.2) : Color.white.opacity(0.08))
                .foregroundStyle(manager.isProxyActive ? Color.green : Color.gray)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(manager.isProxyActive ? Color.green : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.top, 10)
    }

    private var activationRingCard: some View {
        VStack(spacing: 16) {
            Button {
                manager.toggleProxyActivation()
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: manager.isProxyActive ? [.green, neonCyan] : [neonBlue.opacity(0.4), neonCyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 6
                        )
                        .frame(width: 132, height: 132)
                        .shadow(color: manager.isProxyActive ? neonCyan.opacity(0.7) : .clear, radius: 16)

                    Circle()
                        .fill(cardBg)
                        .frame(width: 116, height: 116)

                    VStack(spacing: 6) {
                        Image(systemName: manager.isProxyActive ? "bolt.shield.fill" : "power")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(manager.isProxyActive ? neonCyan : .white.opacity(0.8))
                        Text(manager.isProxyActive ? "ĐANG BẬT" : "KÍCH HOẠT")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(manager.isProxyActive ? neonCyan : .gray)
                    }
                }
            }
            .disabled(!manager.isFileValid || manager.isBusy)

            Text(manager.connectionStatusText)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(manager.isProxyActive ? Color.green : neonCyan)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonCyan.opacity(0.25), lineWidth: 1)
        )
    }

    private var fileImportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill.badge.gearshape")
                    .foregroundStyle(neonCyan)
                Text("NẠP TỆP TỪ IPHONE")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Tên tệp:")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(manager.loadedFileName)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                HStack {
                    Text("Dung lượng:")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(manager.loadedFileSize)
                        .fontWeight(.semibold)
                        .foregroundStyle(neonCyan)
                }
                HStack(alignment: .top) {
                    Text("Trạng thái:")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(manager.validationState)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(manager.isFileValid ? Color.green : Color.orange)
                }
            }
            .font(.system(size: 13))
            .padding(12)
            .background(Color.black.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 10) {
                Button {
                    showFileImporter = true
                } label: {
                    Label("Chọn File từ iPhone", systemImage: "doc.badge.plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [neonBlue, neonCyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    manager.loadBuiltInSampleConfig()
                } label: {
                    Text("Nạp Mẫu")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(neonCyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonCyan.opacity(0.22), lineWidth: 1)
        )
    }

    private func configDetailsCard(_ cfg: ProxyConfig) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(neonCyan)
                Text("THÔNG TIN TỆP TRONG CONTAINER")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Text(cfg.proxyType)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(neonCyan.opacity(0.2))
                    .foregroundStyle(neonCyan)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Divider().background(Color.white.opacity(0.15))

            Group {
                detailRow(title: "Định danh Profile", value: cfg.profileName)
                detailRow(title: "Cổng điều hướng", value: "\(cfg.proxyHost):\(cfg.proxyPort)")
                detailRow(title: "Số mục/dòng đọc được", value: "\(cfg.detectedKeysCount)")
                detailRow(title: "Mã kiểm tra SHA-256", value: cfg.sha256Short)
            }
            .font(.system(size: 13, design: .monospaced))
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonCyan.opacity(0.22), lineWidth: 1)
        )
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)
            Spacer()
            Text(value)
                .foregroundStyle(.white)
        }
    }

    private var switchesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(neonCyan)
                Text("TUỲ CHỌN KÍCH HOẠT")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
            }

            Toggle("Bỏ qua proxy cho mạng nội bộ (LAN)", isOn: $manager.bypassLocalNetwork)
                .tint(neonCyan)
                .font(.system(size: 14))

            Toggle("Kích hoạt DNS tốc độ cao (1.1.1.1)", isOn: $manager.customDNSActive)
                .tint(neonCyan)
                .font(.system(size: 14))

            Toggle("Chỉ nhận file đúng chuẩn JSON", isOn: $manager.strictVerifyJSON)
                .tint(neonCyan)
                .font(.system(size: 14))
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonCyan.opacity(0.22), lineWidth: 1)
        )
    }

    private var consoleLogCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(neonCyan)
                Text("NHẬT KÝ HỆ THỐNG")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button("Xoá") {
                    manager.logs.removeAll()
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 5) {
                    ForEach(manager.logs, id: \.self) { entry in
                        Text(entry)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color(red: 0.65, green: 0.92, blue: 1.0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 130)
            .padding(10)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonCyan.opacity(0.22), lineWidth: 1)
        )
    }
}