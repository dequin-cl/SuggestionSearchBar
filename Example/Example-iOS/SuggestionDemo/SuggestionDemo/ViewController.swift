//
//  ViewController.swift
//  SuggestionDemo
//
//  Created by Iván on 14-10-20.
//

import UIKit
import SuggestionSearchBar

class ViewController: UIViewController {

    @IBOutlet var searchBar: SuggestionSearchBar!
    // Keep information about Keyboard height
    fileprivate var keyboardHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        searchBar.rootViewController = UIApplication.getWindow().rootViewController
        searchBar.delegateSuggestionSearchBar = self
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)


        configureKeyboard()

//        prepareSuggestionWithStrings()
        prepareSuggestionWithSuggestionSearchBarModel()
    }

    func prepareSuggestionWithStrings() {
        let list: [String] = ["Chocolate", "Sugar", "Flour", "Butter", "Vanilla", "Eggs", "Salt", "Yeast"]

        searchBar.setDatas(datas: list)
    }

    func prepareSuggestionWithSuggestionSearchBarModel() {
        var list: [SuggestionSearchBarModel] = []
        list.append(SuggestionSearchBarModel(title: "Alpha", url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Alpha.png"))
        list.append(SuggestionSearchBarModel(title: "Bravo",
                                             url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Bravo.png"))
        list.append(SuggestionSearchBarModel(title: "Charlie",
                                             url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Charlie.png"))
        list.append(SuggestionSearchBarModel(title: "Delta",
                                             url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Delta.png"))
        list.append(SuggestionSearchBarModel(title: "Echo",
                                             url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Echo.png"))
        list.append(SuggestionSearchBarModel(title: "Foxtrot",
                                             url: "https://github.com/dequin-cl/SuggestionSearchBar/raw/main/Screenshots/Foxtrot.png"))

        searchBar.setDatasWithUrl(datas: list)
    }

}

extension ViewController: SuggestionSearchBarDelegate {

    func getKeyboardHeight() -> CGFloat {
        return keyboardHeight
    }

    func onClickItemSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: String) {
        print("Using suggestionSearchBar: \(suggestionSearchBar)")
        print("User touched this item: "+item)
    }

    func onClickItemWithUrlSuggestionsView(suggestionSearchBar: SuggestionSearchBar, item: SuggestionSearchBarModel) {
        print("Using suggestionSearchBar: \(suggestionSearchBar)")
        print("User touched this item: " + item.title + " with this url: " + item.url.absoluteString)
    }
}

extension ViewController {
    fileprivate func configureKeyboard() {
        // register for notifications when the keyboard appears:
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(note:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        // register for notifications when the keyboard disappears:
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardHideShow(note:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // Handle keyboard frame changes here.
    // Use the CGRect stored in the notification to determine what part of the screen the keyboard will cover.
    // Adjust our table view's contentInset and scrollIndicatorInsets properties so that the table view content avoids the part of the screen covered by the keyboard
    @objc func keyboardWillShow(note: NSNotification) {
        // read the CGRect from the notification (if any)
        if let newFrame = (note.userInfo?[ UIResponder.keyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            keyboardHeight = newFrame.height
        }
    }

    @objc func keyboardHideShow(note: NSNotification) {
        keyboardHeight = 0
    }
}
