//
//  PrePromptComponents.swift
//  MannFit
//
//  Created by Daniel Till on 3/26/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import Foundation
import UIKit

enum ApparatusType {
    case PlankBoard
    case PullUpBar
}

class PrePromptComponents {
    
    let apparatusFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 14.0 : 16.0
    }()
    let buttonWidth: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 80.0 : 120.0
    }()
    lazy var stepFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 12.0 : 14.0
    }()
    lazy var buttonFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 18.0 : 22.0
    }()
    let iconWidth: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 35.0 : 50.0
    }()

    struct PullUpStep {
        static let one = "Attach smartphone to center of pull-up bar"
        static let two = "Balance the bar in a pull-up position"
    }
    
    struct PlankBoardStep {
        static let one = "Place smartphone on center of plankboard"
        static let two = "Balance on the plankboard in push-up position"
    }
    
    func title(name: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.textColor = .white
        label.text = name
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func apparatusTitlePlankboard() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: apparatusFontSize)
        label.textColor = .white
        label.text = "Plankboard"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func apparatusTitlePullUpBar() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: apparatusFontSize)
        label.textColor = .white
        label.text = "Pull-Up Bar"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func apparatusSwitch(isOn: Bool) -> UISwitch {
        let switchDemo = UISwitch(frame: CGRect(x: 0, y: 0, width: iconWidth, height: iconWidth))
        switchDemo.isOn = isOn
        switchDemo.setOn(isOn, animated: false)
        switchDemo.layer.borderWidth = 2
        switchDemo.layer.borderColor = UIColor.white.cgColor
        switchDemo.layer.cornerRadius = 16
        switchDemo.tintColor = .clear
        switchDemo.onTintColor = .clear
        switchDemo.translatesAutoresizingMaskIntoConstraints = false
        return switchDemo
    }
    
    func icon(name: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: name))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    func plankStep1() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = PlankBoardStep.one
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func plankStep2() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = PlankBoardStep.two
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func pullUpStep1() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = PullUpStep.one
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func pullUpStep2() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = PullUpStep.two
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func gameStep(_ step: String, numberOfLines: Int) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = step
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func inputLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.textColor = .white
        label.text = "Enter exercise time:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func timeInput() -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            ]
        textField.attributedPlaceholder = NSAttributedString(string: "Seconds", attributes:attributes)
        
        textField.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: buttonFontSize)
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextFieldViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    func startButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10.0
        button.setTitle("START", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func cancelButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10.0
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
