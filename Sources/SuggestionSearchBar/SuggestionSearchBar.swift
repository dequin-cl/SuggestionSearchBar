//
//  SearchBarCompletion.swift
//  SearchBarCompletion
//
//  Created by Philippe on 03/03/2017.
//  Copyright © 2017 CookMinute. All rights reserved.
//

import UIKit
import Foundation

public class SuggestionSearchBar: UISearchBar, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    public enum Choice {
        case normal
        case withUrl
    }

    // MARK: DATAS
    private var isSuggestionsViewOpened: Bool!

    private var suggestionList: [String] = [String]()
    private var suggestionListFiltred: [String] = [String]()

    private var suggestionListWithUrl: [SuggestionSearchBarModel] = [SuggestionSearchBarModel]()
    private var suggestionListWithUrlFiltred: [SuggestionSearchBarModel] = [SuggestionSearchBarModel]()

    private var choice: Choice = .normal

    private var keyboardHeight: CGFloat = 0

    // MARK: VIEWS
    private var suggestionsView: UITableView?
    private var suggestionsShadow: UIView?

    // MARK: DELEGATE
    public var delegateSuggestionSearchBar: SuggestionSearchBarDelegate?

    //PUBLICS OPTIONS
    public var rootViewController: UIViewController!
    public var useShadow: Bool = true
    public var shadowView_alpha: CGFloat = 0.3

    public var searchImage: UIImage?

    public var searchLabel_font: UIFont?
    public var searchLabel_textColor: UIColor?
    public var searchLabel_backgroundColor: UIColor?

    public var suggestionsView_maxHeight: CGFloat!
    public var suggestionsView_backgroundColor: UIColor?
    public var suggestionsView_contentViewColor: UIColor?
    public var suggestionsView_separatorStyle: UITableViewCell.SeparatorStyle = .singleLine
    public var suggestionsView_selectionStyle: UITableViewCell.SelectionStyle = UITableViewCell.SelectionStyle.none
    public var suggestionsView_verticalSpaceWithSearchBar: CGFloat = 3

    public var suggestionsView_searchIcon_height: CGFloat = 17
    public var suggestionsView_searchIcon_width: CGFloat = 17
    public var suggestionsView_searchIcon_isRound = true

    public var suggestionsView_spaceWithKeyboard: CGFloat = 3

    // MARK: INITIALISERS
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init () {
        super.init(frame: CGRect.zero)
        setup()
    }

    private func setup() {
        delegate = self
        isSuggestionsViewOpened = false
        interceptOrientationChange()
        interceptTextfieldTextChange()
        interceptKeyboardChange()
        interceptMemoryWarning()
    }

    private func configureViews() {

        ///Configure suggestionsView (TableView)
        suggestionsView = UITableView(frame: CGRect(x: getSuggestionsViewX(), y: getSuggestionsViewY(), width: getSuggestionsViewWidth(), height: 0))
        suggestionsView!.delegate = self
        suggestionsView!.dataSource = self
        suggestionsView!.register(SuggestionSearchBarCell.self, forCellReuseIdentifier: "cell")
        suggestionsView!.rowHeight = UITableView.automaticDimension
        suggestionsView!.estimatedRowHeight = 100
        suggestionsView!.separatorStyle = suggestionsView_separatorStyle
        if let backgroundColor = suggestionsView_backgroundColor { suggestionsView!.backgroundColor = backgroundColor }

        if useShadow {
            ///Configure the suggestions shadow (Behing the TableView)
            suggestionsShadow = UIView(frame: CGRect(x: getShadowX(), y: getShadowY(), width: getShadowWidth(), height: getShadowHeight()))
            suggestionsShadow?.backgroundColor = UIColor.black.withAlphaComponent(shadowView_alpha)

            ///Configure the gesture to handle click on shadow and improve focus on searchbar
            let gestureShadow = UITapGestureRecognizer(target: self, action: #selector (onClickShadowView (_:)))
            suggestionsShadow?.addGestureRecognizer(gestureShadow)
        }

        let gestureRemoveFocus = UITapGestureRecognizer(target: self, action: #selector (removeFocus (_:)))
        gestureRemoveFocus.cancelsTouchesInView = false
        getViewTopController().addGestureRecognizer(gestureRemoveFocus)

        ///Reload datas of suggestionsView
        suggestionsView!.reloadData()
    }

    // --------------------------------
    // MARK: - SET DATAS
    // --------------------------------

    public func setDatas(datas: [String]) {
        if !suggestionListWithUrl.isEmpty { fatalError("You have already filled 'suggestionListWithUrl' ! You can fill only one list. ") }
        suggestionList = datas
        choice = .normal
    }

    public func setDatasWithUrl(datas: [SuggestionSearchBarModel]) {
        if !suggestionList.isEmpty { fatalError("You have already filled 'suggestionList' ! You can fill only one list. ") }
        suggestionListWithUrl = datas
        choice = .withUrl
    }

    // --------------------------------
    // MARK: - DELEGATE METHODS SEARCH BAR
    // --------------------------------

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWhenUserTyping(caracters: searchText)
        delegateSuggestionSearchBar?.searchBar?(searchBar, textDidChange: searchText)
    }

    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegateSuggestionSearchBar?.searchBarTextDidBeginEditing?(searchBar)
        if suggestionsView == nil { configureViews() }
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        closeSuggestionsView()
        delegateSuggestionSearchBar?.searchBarTextDidEndEditing?(searchBar)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeSuggestionsView()
        delegateSuggestionSearchBar?.searchBarSearchButtonClicked?(searchBar)
        endEditing(true)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSuggestionsView()
        delegateSuggestionSearchBar?.searchBarCancelButtonClicked?(searchBar)
        endEditing(true)
    }

    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if let shouldEndEditing = delegateSuggestionSearchBar?.searchBarShouldEndEditing?(searchBar) {
            return shouldEndEditing
        } else {
            return true
        }
    }

    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let shouldBeginEditing = delegateSuggestionSearchBar?.searchBarShouldBeginEditing?(searchBar) {
            return shouldBeginEditing
        } else {
            return true
        }
    }

    // --------------------------------
    // MARK: - ACTIONS
    // --------------------------------

    ///Handle click on shadow view
    @objc func onClickShadowView(_ sender: UITapGestureRecognizer) {
        delegateSuggestionSearchBar?.onClickShadowView?(suggestionSearchBar: self, shadowView: suggestionsShadow!)
        closeSuggestionsView()
    }

    ///Remove focus when you tap outside the searchbar
    @objc func removeFocus(_ sender: UITapGestureRecognizer) {
        if !isSuggestionsViewOpened { endEditing(true) }
    }

    // --------------------------------
    // MARK: - DELEGATE METHODS TABLE VIEW
    // --------------------------------

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch choice {
        case .normal:
            return suggestionListFiltred.count
        case .withUrl:
            return suggestionListWithUrlFiltred.count
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: SuggestionSearchBarCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SuggestionSearchBarCell

        var title = ""

        switch choice {
        case .normal:
            title = suggestionListFiltred[indexPath.row]
            break
        case .withUrl:
            title = suggestionListWithUrlFiltred[indexPath.row].title
            break
        }

        ///Configure label
        cell.labelModelSearchBar.text = title
        if let font = searchLabel_font { cell.labelModelSearchBar.font = font }
        if let textColor = searchLabel_textColor { cell.labelModelSearchBar.textColor = textColor }
        if let backgroundColor = searchLabel_backgroundColor { cell.labelModelSearchBar.backgroundColor = backgroundColor }

        ///Configure content
        if let contentColor = suggestionsView_contentViewColor { cell.contentView.backgroundColor = contentColor }
        cell.selectionStyle = suggestionsView_selectionStyle

        ///Configure Image
        cell.configureImage(choice: choice, searchImage: searchImage, suggestionsListWithUrl: suggestionListWithUrlFiltred, position: indexPath.row, isImageRound: suggestionsView_searchIcon_isRound, heightImage: suggestionsView_searchIcon_height)
        //fetchImageFromUrl(model: suggestionListWithUrlFiltred[indexPath.row], cell: cell, indexPath: indexPath)

        ///Configure Constraints
        cell.configureConstraints(heightImage: suggestionsView_searchIcon_height, widthImage: suggestionsView_searchIcon_width)

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch choice {
        case .normal:
            delegateSuggestionSearchBar?.onClickItemSuggestionsView?(suggestionSearchBar: self, item: suggestionListFiltred[indexPath.row])
        case .withUrl:
            delegateSuggestionSearchBar?.onClickItemWithUrlSuggestionsView?(suggestionSearchBar: self, item: suggestionListWithUrlFiltred[indexPath.row])
        }
    }

    // --------------------------------
    // MARK: - SEARCH FUNCTION
    // --------------------------------

    ///Main function that is called when user searching
    private func searchWhenUserTyping(caracters: String) {

        switch choice {

        ///Case normal (List of string)
        case .normal:

            var suggestionListFiltredTmp = [String]()
            DispatchQueue.global(qos: .background).async {
                for item in self.suggestionList {
                    if self.researchCaracters(stringSearched: caracters, stringQueried: item) {
                        suggestionListFiltredTmp.append(item)
                    }
                }
                DispatchQueue.main.async {
                    self.suggestionListFiltred.removeAll()
                    self.suggestionListFiltred.append(contentsOf: suggestionListFiltredTmp)
                    self.updateAfterSearch(caracters: caracters)
                }
            }

            break

        ///Case with URL (List of SuggestionSearchBarModel)
        case .withUrl:

            var suggestionListFiltredWithUrlTmp = [SuggestionSearchBarModel]()
            DispatchQueue.global(qos: .background).async {
                for item in self.suggestionListWithUrl {
                    if self.researchCaracters(stringSearched: caracters, stringQueried: item.title) {
                        suggestionListFiltredWithUrlTmp.append(item)
                    }
                }
                DispatchQueue.main.async {
                    self.suggestionListWithUrlFiltred.removeAll()
                    self.suggestionListWithUrlFiltred.append(contentsOf: suggestionListFiltredWithUrlTmp)
                    self.updateAfterSearch(caracters: caracters)
                }
            }

            break
        }
    }

    private func researchCaracters(stringSearched: String, stringQueried: String) -> Bool {
        return ((stringQueried.range(of: stringSearched, options: [String.CompareOptions.caseInsensitive, String.CompareOptions.diacriticInsensitive], range: nil, locale: nil)) != nil)
    }

    private func updateAfterSearch(caracters: String) {
        if suggestionsView == nil {
            configureViews()
        } else {
            suggestionsView!.frame = CGRect(x: getSuggestionsViewX(), y: getSuggestionsViewY(), width: getSuggestionsViewWidth(), height: 0)
        }
        suggestionsView!.reloadData()
        caracters.isEmpty ? closeSuggestionsView() : openSuggestionsView()
        updateSizeSuggestionsView()
    }

    // --------------------------------
    // MARK: - SUGGESTIONS VIEW UTILS
    // --------------------------------

    private func haveToOpenSuggestionView() -> Bool {
        switch choice {
        case .normal:
            return !suggestionListFiltred.isEmpty
        case .withUrl:
            return !suggestionListWithUrlFiltred.isEmpty
        }
    }

    private func openSuggestionsView() {
        if haveToOpenSuggestionView() {
            if !isSuggestionsViewOpened {
                animationOpening()

                if useShadow {
                    addViewToParent(view: suggestionsShadow!)
                }

                addViewToParent(view: suggestionsView!)
                isSuggestionsViewOpened = true
                suggestionsView!.reloadData()
            }
        }
    }

    private func closeSuggestionsView() {
        if isSuggestionsViewOpened == true {
            animationClosing()
            isSuggestionsViewOpened = false
        }
    }

    private func animationOpening() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.suggestionsView?.alpha = 1.0
            self.suggestionsShadow?.alpha = 1.0
        }, completion: nil)
    }

    private func animationClosing() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.suggestionsView?.alpha = 0.0
            self.suggestionsShadow?.alpha = 0.0
        }, completion: nil)
    }

    // --------------------------------
    // MARK: - VIEW UTILS
    // --------------------------------

    private func getSuggestionsViewX() -> CGFloat {
        return getGlobalPointEditText().x
    }

    private func getSuggestionsViewY() -> CGFloat {
        return getShadowY() - suggestionsView_verticalSpaceWithSearchBar
    }

    private func getSuggestionsViewWidth() -> CGFloat {
        return getEditText().frame.width
    }

    private func getSuggestionsViewHeight() -> CGFloat {
        return getEditText().frame.height
    }

    private func getShadowX() -> CGFloat {
        return 0
    }

    private func getShadowY() -> CGFloat {
        return getGlobalPointEditText().y + getEditText().frame.height
    }

    private func getShadowHeight() -> CGFloat {
        return (getTopViewController()?.view.frame.height)!
    }

    private func getShadowWidth() -> CGFloat {
        return (getTopViewController()?.view.frame.width)!
    }

    private func updateSizeSuggestionsView() {
        var frame: CGRect = suggestionsView!.frame
        frame.size.height = getExactMaxHeightSuggestionsView(newHeight: suggestionsView!.contentSize.height)

        UIView.animate(withDuration: 0.3) {
            self.suggestionsView!.frame = frame
            self.suggestionsView!.layoutIfNeeded()
            self.suggestionsView!.sizeToFit()
        }
    }

    private func getExactMaxHeightSuggestionsView(newHeight: CGFloat) -> CGFloat {
        var estimatedMaxView: CGFloat!
        if suggestionsView_maxHeight != nil {
            estimatedMaxView = suggestionsView_maxHeight
        } else {
            estimatedMaxView = getEstimateHeightSuggestionsView()
        }

        if newHeight > estimatedMaxView {
            return estimatedMaxView
        } else {
            return newHeight
        }
    }

    private func getEstimateHeightSuggestionsView() -> CGFloat {
        if let delegateKeyboardHeight = delegateSuggestionSearchBar?.getKeyboardHeight(), delegateKeyboardHeight > 0 {
            keyboardHeight = delegateKeyboardHeight
        }

        return getViewTopController().frame.height
            - getShadowY()
            - keyboardHeight
            - suggestionsView_spaceWithKeyboard
    }

    // --------------------------------
    // MARK: - UTILS
    // --------------------------------

    private func clearCacheOfList() {
        ///Clearing cache
        for suggestionItem in suggestionListWithUrl {
            suggestionItem.imgCache = nil
        }
        ///Clearing cache
        for suggestionItem in suggestionListWithUrlFiltred {
            suggestionItem.imgCache = nil
        }
        suggestionsView?.reloadData()
    }

    private func addViewToParent(view: UIView) {
        if let topController = getTopViewController() {
            let superView: UIView = topController.view
            superView.addSubview(view)
        }
    }

    private func getViewTopController() -> UIView {
        return getTopViewController()!.view
    }

    private func getTopViewController() -> UIViewController? {

        var topController = self.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }

        if topController is UINavigationController {
            topController = (topController as! UINavigationController).visibleViewController
        }

        return topController
    }

    private func getEditText() -> UITextField {
        return value(forKey: "searchField") as! UITextField
    }

    private func getText() -> String {
        if let text = getEditText().text {
            return text
        } else {
            return ""
        }
    }

    private func getGlobalPointEditText() -> CGPoint {
        return getEditText().superview!.convert(getEditText().frame.origin, to: nil)
    }

    // --------------------------------
    // MARK: - OBSERVERS CHANGES
    // --------------------------------

    private func interceptOrientationChange() {
        getEditText().addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            closeSuggestionsView()
        }
    }

    private func interceptTextfieldTextChange() {
        getEditText().addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc
    private func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else { return }
        delegateSuggestionSearchBar?.onTextChangedOnSearchBar?(suggestionSearchBar: self, text: text)
    }

    // ---------------

    private func interceptKeyboardChange() {
        NotificationCenter.default.addObserver( self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: self.getEditText())
        NotificationCenter.default.addObserver( self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: self.getEditText()
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
        let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! CGRect
        let keyboardHeight = keyboardFrame.height

        self.keyboardHeight = keyboardHeight
        updateSizeSuggestionsView()
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        updateSizeSuggestionsView()
    }

    // ---------------

    private func interceptMemoryWarning() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning(notification:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    @objc private func didReceiveMemoryWarning(notification: NSNotification) {
        clearCacheOfList()
    }

    // --------------------------------
    // MARK: - PUBLIC ACCESS
    // --------------------------------

    public func getSuggestionsView() -> UITableView? {
        return suggestionsView
    }

}

extension SuggestionSearchBar {

    open var searchUITextField: UITextField {
        get {
            if #available(iOS 13, *) {
                return super.searchTextField
            } else {
                return getEditText()
            }
        }
    }
}
