//
//  SuggestionSearchBarCell.swift
//  SearchBarCompletion
//
//  Created by Philippe on 06/03/2017.
//  Copyright © 2017 CookMinute. All rights reserved.
//

import UIKit

public class SuggestionSearchBarCell: UITableViewCell {

    public static let defaultMargin: CGFloat = 10

    let imgSuggestionSearchBar = UIImageView()
    var labelModelSearchBar = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        ///Setup image
        imgSuggestionSearchBar.translatesAutoresizingMaskIntoConstraints = false
        imgSuggestionSearchBar.contentMode = .scaleAspectFill

        ///Setup label
        labelModelSearchBar.translatesAutoresizingMaskIntoConstraints = false
        labelModelSearchBar.numberOfLines = 0
        labelModelSearchBar.lineBreakMode = NSLineBreakMode.byWordWrapping

        contentView.addSubview(imgSuggestionSearchBar)
        contentView.addSubview(labelModelSearchBar)
    }

    ///Configure constraint for each row of suggestionsView
    public func configureConstraints(heightImage: CGFloat, widthImage: CGFloat) {

        ///Image constraints
        NSLayoutConstraint.deactivate(contentView.constraints)

        imgSuggestionSearchBar.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true
        imgSuggestionSearchBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true

        imgSuggestionSearchBar.heightAnchor.constraint(equalToConstant: heightImage).isActive = true
        imgSuggestionSearchBar.widthAnchor.constraint(equalToConstant: widthImage).isActive = true

        ///Label constraints
        if imgSuggestionSearchBar.image != nil {
            labelModelSearchBar.leftAnchor.constraint(equalTo: imgSuggestionSearchBar.rightAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true
        } else {
            labelModelSearchBar.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true
        }
        labelModelSearchBar.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true
        labelModelSearchBar.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true
        labelModelSearchBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        labelModelSearchBar.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: SuggestionSearchBarCell.defaultMargin).isActive = true

    }

    ///Configure image of suggestionsView
    public func configureImage(choice: SuggestionSearchBar.Choice, searchImage: UIImage?, suggestionsListWithUrl: [SuggestionSearchBarModel], position: Int, isImageRound: Bool, heightImage: CGFloat) {
        switch choice {
            ///Show image from asset
            case .normal:
                imgSuggestionSearchBar.image = searchImage
                break
            ///Show image from URL
            case .withUrl:
                let model = suggestionsListWithUrl[position]
                if model.imgCache != nil {
                    imgSuggestionSearchBar.image = model.imgCache
                } else {
                    downloadImage(model: model)
                }
                break
        }

        if isImageRound {
            imgSuggestionSearchBar.layer.cornerRadius = heightImage / 2
            imgSuggestionSearchBar.clipsToBounds = true
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        labelModelSearchBar.preferredMaxLayoutWidth = labelModelSearchBar.frame.size.width
    }

    //----------------------------

    func downloadImage(model: SuggestionSearchBarModel) {
        DispatchQueue.global(qos: .background).async {
            self.getDataFromUrl(url: model.url) { (data, _, error)  in
                guard let data = data, error == nil else { return }
                let image = UIImage(data: data)
                DispatchQueue.main.async { () -> Void in
                    model.imgCache = image
                    self.imgSuggestionSearchBar.image = image
                }
            }
        }
    }

    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in

            completion(data, response, error)
        }.resume()
    }
}
