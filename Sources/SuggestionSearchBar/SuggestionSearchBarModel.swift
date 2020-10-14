//
//  SuggestionSearchBarModel.swift
//  SearchBarCompletion
//

import UIKit

public class SuggestionSearchBarModel: NSObject {

    public var title: String!
    public var url: URL!
    public var imgCache: UIImage!

    public init(title: String, url: String) {
        super.init()
        self.title = title
        if let newUrl = URL(string: url) {
            self.url = newUrl
        } else {
            print("SuggestionSearchBarModel: Seems url is not valid...")
            self.url = URL(string: "#")
        }
    }
}
