//
//  File.swift
//  
//
//  Created by Mattia Righetti on 21/10/23.
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
        case recommend
        case news
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
            .recommend, .news
            // .active, .asknew, .news, .classic, .recommend,
            // .invited, .launches, .noobstories, .pool,
            // .shownew, .whoishiring
        ]

        var url: URL {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "www.clien.net"
            
           switch self {
           case .recommend:
               urlComponents.path = "/service/recommend"
           case .news:
               urlComponents.path = "/service/board/news"
           default:
               urlComponents.path = "/service/recommend"
           }

            return urlComponents.url!
        }
    }

    public static let shared = HNPageFetcher()

    private init() {}

    private func getArticles(from list: HNList? = .recommend) async throws -> Data {
        var req = URLRequest(url: list!.url)
        
//        req.setValue("ClienWidgets", forHTTPHeaderField: "User-Agent")

        let (data, res) = try await URLSession.shared.data(for: req)
        guard let httpResponse = res as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            NSLog("httpResponse is not 200")
            throw FetchError.failure
        }

        return data
    }

    public func getHNLinks(from list: HNList? = .recommend) async -> Result<[HNLink], Error> {
        
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

        NSLog("Try getHNLinks")

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
