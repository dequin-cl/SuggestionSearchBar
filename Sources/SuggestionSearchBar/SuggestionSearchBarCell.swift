//
//  SuggestionSearchBarCell.swift
//  SearchBarCompletion
//
//  Created by Philippe on 06/03/2017.
//  Copyright © 2017 CookMinute. All rights reserved.
//

import UIKit

public class SuggestionSearchBarCell: UITableViewCell {

    private var imageSize: CGSize = .zero
    private var stackView: UIStackView!
    private(set) var label: UILabel!
    private var imageContainerView: UIImageView!
    private var modelImage: UIImage?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {

        imageContainerView = UIImageView(image: UIImage())
        let aContainerView = UIView()

        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        aContainerView.addSubview(imageContainerView)
        aContainerView.translatesAutoresizingMaskIntoConstraints = false

        label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.addSubview(label)

        label.topAnchor.constraint(equalTo: labelContainer.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true

        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = imageSize == .zero ? 0: 16
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

        stackView.addArrangedSubview(aContainerView)
        stackView.addArrangedSubview(labelContainer)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
    }

    ///Configure image of suggestionsView
    public func configureImage(choice: SuggestionSearchBar.Choice,
                               suggestionsListWithUrl: [SuggestionSearchBarModel],
                               position: Int,
                               isImageRound: Bool,
                               imageSize: CGSize) {

        self.imageSize = imageSize

        switch choice {
            ///Show image from asset
            case .normal:
                break
            ///Show image from URL
            case .withUrl:
                var model = suggestionsListWithUrl[position]
                if model.imgCache != nil {
                    processImage(image: model.imgCache)

                } else {
                    if model.url.absoluteString != "#" {
                        downloadImage(imageURL: model.url) { (image) in
                            model.addImage(image)
                            self.processImage(image: image)
                        }
                    }
                }
                break
        }

        if isImageRound {
            imageContainerView?.layer.cornerRadius = imageSize.height / 2
            imageContainerView?.clipsToBounds = true
        }
    }

    private func processImage(image: UIImage?) {
        modelImage = image
        imageContainerView?.image = modelImage
    }

    fileprivate func adjustImageContainerConstraints() {
        NSLayoutConstraint.deactivate(imageContainerView.constraints)

        let aContainerView = imageContainerView.superview!
        var constraints: [NSLayoutConstraint]!

        if imageSize == .zero {
            constraints = [
                imageContainerView.leadingAnchor.constraint(equalTo: aContainerView.leadingAnchor, constant: 0),
                imageContainerView.trailingAnchor.constraint(equalTo: aContainerView.trailingAnchor, constant: 0),
                imageContainerView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
                imageContainerView.heightAnchor.constraint(equalToConstant: imageSize.height),
                imageContainerView.widthAnchor.constraint(equalToConstant: imageSize.width),
                aContainerView.widthAnchor.constraint(equalToConstant: 0)
            ]
        } else {
            constraints = [
                imageContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: aContainerView.leadingAnchor, constant: 5),
                imageContainerView.trailingAnchor.constraint(greaterThanOrEqualTo: aContainerView.trailingAnchor, constant: -5),
                imageContainerView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
                imageContainerView.heightAnchor.constraint(equalToConstant: imageSize.height),
                imageContainerView.widthAnchor.constraint(equalToConstant: imageSize.width),
                aContainerView.widthAnchor.constraint(equalToConstant: (imageSize.width + 10))
            ]
        }

        constraints.forEach {
            $0.priority = .required
            $0.isActive = true
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        adjustImageContainerConstraints()
    }

    //----------------------------

    func downloadImage(imageURL: URL,  success: @escaping (UIImage?) -> ()) {

        DispatchQueue.global(qos: .background).async {
            self.getDataFromUrl(url: imageURL) { (data, _, error)  in
                guard let data = data, error == nil else { return }
                let image = UIImage(data: data)
                DispatchQueue.main.async { () -> Void in
                    success(image)
                    self.imageContainerView?.image = image
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
