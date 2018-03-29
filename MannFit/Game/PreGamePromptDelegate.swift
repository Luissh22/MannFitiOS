//
//  PreGamePromptDelegate.swift
//  MannFit
//
//  Created by Daniel Till on 1/11/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import Foundation

protocol PreGamePromptDelegate: NSObjectProtocol {
    func startGame(time: TimeInterval?, apparatusType: ApparatusType?)
    func cancelGame()
}
