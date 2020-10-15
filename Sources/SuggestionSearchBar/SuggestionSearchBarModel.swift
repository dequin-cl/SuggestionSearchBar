//
//  SuggestionSearchBarModel.swift
//  SearchBarCompletion
//

import UIKit

public struct SuggestionSearchBarModel {

    public private(set) var title: String
    public private(set) var url: URL
    private(set) var imgCache: UIImage?

    public init(title: String, url: String) {
        self.title = title
        if let newUrl = URL(string: url) {
            self.url = newUrl
        } else {
            debugPrint("SuggestionSearchBarModel: Seems url is not valid...")
            self.url = URL(string: "#")!
        }
    }

    mutating func addImage(_ image: UIImage?) {
        imgCache = image
    }

    mutating func clearCache() {
        imgCache = nil
    }
}
