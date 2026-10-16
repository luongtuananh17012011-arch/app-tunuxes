import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        guard let protocolConfig = self.protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfig = protocolConfig.providerConfiguration else {
            let err = NSError(domain: "com.tuna.proxy.tunnel", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Thiếu dữ liệu cấu hình providerConfiguration."
            ])
            completionHandler(err)
            return
        }

        let proxyHost = (providerConfig["proxyHost"] as? String) ?? "127.0.0.1"
        let proxyPort = (providerConfig["proxyPort"] as? Int) ?? 8080
        let dnsServers = (providerConfig["dnsServers"] as? [String]) ?? ["1.1.1.1", "8.8.8.8"]
        let bypassLocal = (providerConfig["bypassLocal"] as? Bool) ?? true

        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: proxyHost)
        networkSettings.mtu = 1400

        let ipv4Settings = NEIPv4Settings(addresses: ["198.18.0.1"], subnetMasks: ["255.255.255.0"])
        networkSettings.ipv4Settings = ipv4Settings

        let dnsSettings = NEDNSSettings(servers: dnsServers)
        dnsSettings.matchDomains = [""]
        networkSettings.dnsSettings = dnsSettings

        let proxySettings = NEProxySettings()
        let proxyServer = NEProxyServer(address: proxyHost, port: proxyPort)
        proxySettings.httpEnabled = true
        proxySettings.httpServer = proxyServer
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = proxyServer
        proxySettings.excludeSimpleHostnames = bypassLocal
        if bypassLocal {
            proxySettings.exceptionList = ["localhost", "127.0.0.1", "*.local", "192.168.0.0/16", "10.0.0.0/8"]
        }
        networkSettings.proxySettings = proxySettings

        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}