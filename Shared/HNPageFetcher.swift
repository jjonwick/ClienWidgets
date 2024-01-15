//
//  File.swift
//  
//
//  Created by Mattia Righetti on 21/10/23.
//  Modified by jjonwick for clien on 14/01/24
//

import Foundation

enum FetchError: Error {
    case failure
}

enum ParserError: Error {
    case htmlParseError
    case unknown
}

struct HNPageFetcher {
    enum HNList: String, CaseIterable {
        case 추천글
        case 새소식
        // case shownew
        // case asknew
        // case launches
        // case whoishiring
        // case pool
        // case invited
        // case active
        // case noobstories
        // case classic

        static var allCases: [HNPageFetcher.HNList] = [
            .추천글, .새소식
            // .active, .asknew, .news, .classic, .recommend,
            // .invited, .launches, .noobstories, .pool,
            // .shownew, .whoishiring
        ]

        var url: URL {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "www.clien.net"
            
           switch self {
           case .추천글:
               urlComponents.path = "/service/recommend"
           case .새소식:
               urlComponents.path = "/service/board/news"
           default:
               urlComponents.path = "/service/recommend"
           }

            return urlComponents.url!
        }
    }

    public static let shared = HNPageFetcher()

    private init() {}

    private func getArticles(from list: HNList? = .추천글) async throws -> Data {
        var req = URLRequest(url: list!.url)
        
//        req.setValue("ClienWidgets", forHTTPHeaderField: "User-Agent")

        let (data, res) = try await URLSession.shared.data(for: req)
        guard let httpResponse = res as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            NSLog("httpResponse is not 200")
            throw FetchError.failure
        }

        return data
    }

    public func getHNLinks(from list: HNList? = .추천글) async -> Result<[HNLink], Error> {
        
        guard let data = try? await getArticles(from: list) else {
            NSLog("Failed to getArticles")
            return .failure(FetchError.failure)
        }

        guard
            let htmlString = String(data: data, encoding: .utf8),
            let parser = HTMLParser(html: htmlString)
        else {
            NSLog("Parse error")
            return .failure(ParserError.htmlParseError)
        }

        let links = parser.getHNLinks()
        if links.count > 0 {
            return .success(links)
        }
        else {
            NSLog("No items parsed")
        }
        
        NSLog("ParserError.unknown")
        return .failure(ParserError.unknown)
    }
}
