//
//  SuggestionSearchBarDelegate.swift
//  SearchBarCompletion
//

import UIKit

public protocol SuggestionSearchBarDelegate: UISearchBarDelegate {
    func onClickShadowView(suggestionSearchBar: SuggestionSearchBar, shadowView: UIView)
    func onClickItemSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: String)
    func onClickItemWithUrlSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: SuggestionSearchBarModel)
    func onTextChangedOnSearchBar(suggestionSearchBar: SuggestionSearchBar, text: String)

    func getKeyboardHeight() -> CGFloat
}

public extension SuggestionSearchBarDelegate {

    func onClickShadowView(suggestionSearchBar: SuggestionSearchBar, shadowView: UIView) {
        debugPrint("onClickShadowView: Default Implementation is Empty")
    }

    func onClickItemSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: String) {
        debugPrint("onClickItemSuggestionsView: Default Implementation is Empty")
    }

    func onClickItemWithUrlSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: SuggestionSearchBarModel) {
        debugPrint("onClickItemWithUrlSuggestionsView: Default Implementation is Empty")
    }

    func onTextChangedOnSearchBar(suggestionSearchBar: SuggestionSearchBar, text: String) {
        debugPrint("onTextChangedOnSearchBar: Default Implementation is Empty")
    }
}
