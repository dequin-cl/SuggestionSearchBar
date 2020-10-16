//
//  UIApplication.swift
//  SuggestionDemo
//
//  Created by Iván on 15-10-20.
//

import UIKit

extension UIApplication {

    public static func getWindow() -> UIWindow {

        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
            else {
                fatalError("Should have a window!")
            }

            return sceneDelegate.window!
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.window!
        }
    }
}
