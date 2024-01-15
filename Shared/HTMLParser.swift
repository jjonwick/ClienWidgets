//
//  File.swift
//  
//
//  Created by Mattia Righetti on 21/10/23.
//

import Kanna
import Foundation

public enum Datum {
    case Athing(id: String, innerHtml: XMLElement)
}

public class HTMLParser {
    private let document: HTMLDocument

    public init?(html: String) {
        guard let document = try? Kanna.HTML(html: html, encoding: .utf8) else { return nil }
        self.document = document
    }

    public func getElements() -> [Datum] {
        
        NSLog("get items")

        guard
            let items = document.body?.xpath("//div[@data-role='list-row']")
        else { return [] }
        
        NSLog("number of items: \(items.count)")

        var data = [Datum]()
        for item in items {
            guard let id = item["data-board-sn"] else { continue }
            data.append(Datum.Athing(id: id, innerHtml: item))
        }

        return data
    }

    private func getHNLink(_ obj: Datum) -> HNLink? {
        if case .Athing(let id, let innerHtml) = obj {
            
            guard
                let subject = innerHtml.xpath("//a[@class='list_subject']").first,
                let title_orig = subject.xpath("//span[@data-role='list-title-text']").first?.text,
                let url_path = subject["href"]
            else { return nil }

            let url = "https://www.clien.net" + url_path
            let title = title_orig.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let username = innerHtml["data-author-id"]
            let age = innerHtml.xpath("//div[@class='list_time']//span").first?.text
            let age_trimmed = age?.trimmingCharacters(in: .whitespacesAndNewlines)
            let age_first_5 = age_trimmed?.prefix(5)
            let age_first_5_string = String(age_first_5 ?? "NA")
            let upvotes = innerHtml.xpath("//div[@data-role='list-like-count']//span").first?.text?.leaveNumbers // 공감
            let comments = innerHtml["data-comment-count"]

            return HNLink(id: id, title: title, url: url, username: username, comments: comments, upvotes: upvotes, elapsed: age_first_5_string)
        }

        return nil
    }

    public func getHNLinks() -> [HNLink] {
        getElements()
            .compactMap { x in
                getHNLink(x)
            }
    }
}

extension String {
    var leaveNumbers: String {
        self.trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespaces)
    }
}
