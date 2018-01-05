//
//  GameOverDelegate.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-11-23.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import Foundation

protocol GameOverDelegate: NSObjectProtocol {
    func presentPrompt() -> Void
    func sendGameData(game: String, duration: Int, absement: Float) -> Void
}
