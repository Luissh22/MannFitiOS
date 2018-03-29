//
//  TestingPreGamePromptView.swift
//  MannFit
//
//  Created by Daniel Till on 1/24/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import UIKit

class TestingPreGamePromptView: PreGamePromptView {
    
    struct Game1Step {
        static let one = "Simple testing game to present accelerometer data"
    }
    
    private let viewHeight: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 200.0 : 250.0
    }()
    private let buttonWidth: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 80.0 : 120.0
    }()
    private lazy var stepFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 12.0 : 14.0
    }()
    private lazy var buttonFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 18.0 : 22.0
    }()
    private let iconWidth: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 35.0 : 50.0
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.textColor = .white
        label.text = GameData.testingName
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var step1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: stepFontSize)
        label.textColor = .white
        label.text = Game1Step.one
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var icon1: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "testingGameImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10.0
        button.setTitle("START", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 10.0
        button.setTitle("CANCEL", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(cancelGame), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 30.0
        self.backgroundColor = UIColor.darkGray
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.title)
        
        // step 1
        self.addSubview(self.step1)
        self.addSubview(self.icon1)
        
        self.addSubview(self.startButton)
        self.addSubview(self.cancelButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalPadding: CGFloat = 20.0
        let verticalPadding: CGFloat = 20.0
        
        let titleSize: CGSize = title.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        let step1Size: CGSize = step1.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        
        let startButtonSize: CGSize = startButton.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        let cancelButtonSize: CGSize = cancelButton.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: self.bounds.width),
            self.heightAnchor.constraint(equalToConstant: self.viewHeight)
            ])
        
        NSLayoutConstraint.activate([
            self.title.widthAnchor.constraint(equalToConstant: titleSize.width),
            self.title.heightAnchor.constraint(equalToConstant: titleSize.height),
            self.title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.title.centerYAnchor.constraint(equalTo: self.topAnchor, constant: titleSize.height / 2 + 20.0),
            ])
        
        
        // step 1
        NSLayoutConstraint.activate([
            self.step1.heightAnchor.constraint(equalToConstant: step1Size.height),
            self.step1.trailingAnchor.constraint(equalTo: self.icon1.leadingAnchor, constant: -10.0),
            self.step1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalPadding),
            self.step1.centerYAnchor.constraint(equalTo: self.title.bottomAnchor, constant: iconWidth / 2 + verticalPadding),
            ])
        NSLayoutConstraint.activate([
            self.icon1.widthAnchor.constraint(equalToConstant: iconWidth),
            self.icon1.heightAnchor.constraint(equalToConstant: iconWidth),
            self.icon1.centerXAnchor.constraint(equalTo: self.trailingAnchor, constant: -iconWidth / 2 - horizontalPadding),
            self.icon1.centerYAnchor.constraint(equalTo: self.step1.centerYAnchor),
            ])
        
        NSLayoutConstraint.activate([
            self.startButton.widthAnchor.constraint(lessThanOrEqualToConstant: buttonWidth),
            self.startButton.heightAnchor.constraint(equalToConstant: startButtonSize.height),
            self.startButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonWidth / 2 + horizontalPadding),
            self.startButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalPadding),
            self.startButton.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant:  -buttonWidth / 2),
            ])
        
        NSLayoutConstraint.activate([
            self.cancelButton.widthAnchor.constraint(lessThanOrEqualToConstant: buttonWidth),
            self.cancelButton.heightAnchor.constraint(equalToConstant: cancelButtonSize.height),
            self.cancelButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonWidth / 2 - horizontalPadding),
            self.cancelButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalPadding),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.startButton.centerYAnchor),
            ])
    }
    
    @objc private func startGame() {
        self.delegate?.startGame(time: nil, apparatusType: nil)
    }
    
    @objc private func cancelGame() {
        self.delegate?.cancelGame()
    }
}
