//
//  HNWidgetEntryView.swift
//  HNWidgetExtension
//
//  Created by Mattia Righetti on 21/10/23.
//

import SwiftUI
import WidgetKit

struct HNWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily

    var limit: Int {
        switch widgetFamily {
        case .systemSmall:
            return 0
        case .systemMedium:
            return 3
        case .systemLarge, .systemExtraLarge:
            return 7
        default:
            return 0
        }
    }

    var spacing: (Double, Double, Double) {
        switch widgetFamily {
        case .systemMedium:
            return (2,0.2,0.2)
        case .systemExtraLarge, .systemLarge:
            return (0,5,5)
        default:
            return (0,0,0)
        }
    }

    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Hacker News")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.top, spacing.0)
                    .padding(.bottom, spacing.1)

                Text(entry.list)
                    .font(.system(size: 13, weight: .thin))
                    .padding(.top, spacing.0)
                    .padding(.bottom, spacing.1)
            }

            VStack(alignment: .leading) {
                if entry.links.count >= limit {
                    ForEach(entry.links[0..<limit]) { link in
                        Link(destination: URL(string: "hnwidgets://openlink?link=\(link.url)")!, label: {
                            HNLinkRow(link: link)
                                .padding(.bottom, spacing.2)
                        })
                    }
                } else {
                    Text("No data")
                }
            }
        }.padding(0)
    }
}


