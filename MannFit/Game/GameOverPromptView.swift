//
//  GameOverPromptView.swift
//  MannFit
//
//  Created by Daniel Till on 11/26/17.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import UIKit

class GameOverPromptView: UIView {
    
    weak var delegate: GameOverPromptDelegate?
    private let buttonWidth: CGFloat = 100.0
    private let buttonFontSize: CGFloat = 25.0

    private lazy var restartButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("RESTART", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNextCondensed-Heavy", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle("EXIT", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNextCondensed-Heavy", size: buttonFontSize)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(exitGame), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 30.0
        self.backgroundColor = UIColor.gray
        self.translatesAutoresizingMaskIntoConstraints = false
    
        self.addSubview(self.restartButton)
        self.addSubview(self.exitButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewHeight: CGFloat = 200.0
        let horizontalPadding: CGFloat = 20.0
        
        let restartButtonSize: CGSize = restartButton.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        let exitButtonSize: CGSize = exitButton.sizeThatFits(CGSize(width: 100.0, height: CGFloat.greatestFiniteMagnitude))
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: self.bounds.width),
            self.heightAnchor.constraint(equalToConstant: viewHeight)
            ])
    
        NSLayoutConstraint.activate([
            self.restartButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            self.restartButton.heightAnchor.constraint(equalToConstant: restartButtonSize.height),
            self.restartButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonWidth / 2 + horizontalPadding),
            self.restartButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
        
        NSLayoutConstraint.activate([
            self.exitButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            self.exitButton.heightAnchor.constraint(equalToConstant: exitButtonSize.height),
            self.exitButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonWidth / 2 - horizontalPadding),
            self.exitButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
    }
    
    @objc private func restartGame() {
        self.delegate?.restartGame()
    }
    
    @objc private func exitGame() {
        self.delegate?.exitGame()
    }
}
