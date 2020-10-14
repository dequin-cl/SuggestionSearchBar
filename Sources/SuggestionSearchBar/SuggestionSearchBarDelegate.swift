//
//  SuggestionSearchBarDelegate.swift
//  SearchBarCompletion
//

import UIKit

@objc public protocol SuggestionSearchBarDelegate: UISearchBarDelegate {
    @objc optional func onClickShadowView(suggestionSearchBar: SuggestionSearchBar, shadowView: UIView)
    @objc optional func onClickItemSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: String)
    @objc optional func onClickItemWithUrlSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: SuggestionSearchBarModel)
    
    func onTextChangedOnSearchBar(suggestionSearchBar: SuggestionSearchBar, text: String)
    func getKeyboardHeight() -> CGFloat
    var rootViewController: UIViewController { get set }
}
