import Foundation

enum BinanceError: Error {
    case invalidResponse
    case invalidData
    case networkError(Error)
    case apiError(String)
}

protocol CryptocurrencyDataService {
    func fetchKlines(for symbol: String) async throws -> [Double]
}

final class BinanceService: CryptocurrencyDataService {
    private let baseURL = "https://api.binance.com/api/v3"
    private let session: URLSession
    
    init() {
        // Create a new session configuration to avoid reuse issues
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
    }
    
    // For testing purposes
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchKlines(for symbol: String) async throws -> [Double] {
        let url = try buildURL(for: symbol)
        let request = buildRequest(for: url)
        
        print("🌐 Fetching data for \(symbol) from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(response, data: data)
            return try parseKlines(from: data)
        } catch let error as BinanceError {
            print("🚨 BinanceError for \(symbol): \(error)")
            throw error
        } catch {
            print("🚨 Network error for \(symbol): \(error)")
            throw BinanceError.networkError(error)
        }
    }
    
    private func buildURL(for symbol: String) throws -> URL {
        var components = URLComponents(string: "\(baseURL)/klines")!
        components.queryItems = [
            URLQueryItem(name: "symbol", value: "\(symbol)USDT"),
            URLQueryItem(name: "interval", value: "1m"),
            URLQueryItem(name: "limit", value: "1440")
        ]
        
        guard let url = components.url else {
            throw BinanceError.invalidResponse
        }
        
        return url
    }
    
    private func buildRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        request.httpShouldHandleCookies = false
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return request
    }
    
    private func validateResponse(_ response: URLResponse?, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BinanceError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["msg"] as? String {
                throw BinanceError.apiError(errorMessage)
            }
            throw BinanceError.invalidResponse
        }
    }
    
    private func parseKlines(from data: Data) throws -> [Double] {
        guard let klines = try? JSONSerialization.jsonObject(with: data) as? [[Any]] else {
            throw BinanceError.invalidData
        }
        
        return klines.compactMap { kline in
            guard kline.count >= 4,
                  let highStr = kline[2] as? String,
                  let lowStr = kline[3] as? String,
                  let high = Double(highStr),
                  let low = Double(lowStr) else {
                return nil
            }
            return (high + low) / 2
        }
    }
} 
