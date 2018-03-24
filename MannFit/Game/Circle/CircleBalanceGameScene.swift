//
//  CircleBalanceGameScene.swift
//  MannFit
//
//  Created by Daniel Till on 2/1/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class CircleBalanceGameScene: SKScene {
    
    // MARK: Initilization
    private let motionManager = CMMotionManager()
    private let userDefaults: UserDefaults = UserDefaults.standard
    var engine: AudioEngine?
    weak var gameOverDelegate: GameOverDelegate?
    
    private var gameTimer: Timer?
    private var gameActive: Bool = false
    var inputTime: TimeInterval = GameData.pacmanDefaultTime
    private lazy var exerciseTime: TimeInterval = {
        return inputTime
    }()
    private lazy var timeLeft: TimeInterval = {
        return exerciseTime
    }()
    private var timerSet: Bool = false
    private var timeLabel = SKLabelNode()
    
    // player center calibration
    private var playerCenterX: Double = 0.0
    private var playerCenterY: Double = 0.0
    
    private let background = SKSpriteNode()
    private let absementLabel = SKLabelNode()
    private let absementScoreLabel = SKLabelNode()
    private var absement: Double = 0
    private var absementScore: Double = 0
    private let stopButton = SKSpriteNode(imageNamed: "menu-icon")
    private let centerButton = SKSpriteNode(imageNamed: "center-icon")
    
    private let player = SKShapeNode(circleOfRadius: 10.0)
    private let targetRadius: CGFloat = 20.0
    private let target = SKShapeNode(circleOfRadius: 20.0)
    
    private let countDownLabel = SKLabelNode()
    private let countDownString = "Starting in...%d"
    private var countDown: Int = 10
    private var countDownTimer: Timer?
    
    private lazy var labelFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 40.0 : 50.0
    }()
    private lazy var countDownLabelFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 30.0 : 40.0
    }()
    private lazy var buttonSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 50.0 : 60.0
    }()

    private var smoothXAcceleration = LowPassFilterSignal(value: 0, timeConstant: 0.90)
    private var smoothYAcceleration = LowPassFilterSignal(value: 0, timeConstant: 0.90)
    
    override func didMove(to view: SKView) {
        
        // background setup
        let bounds:CGSize = frame.size
        backgroundColor = SKColor.black
        background.zPosition = -10.0
        background.scale(to: frame.size)
        
        // absementLabel setup
        absementLabel.zPosition = 1
        absementLabel.fontName = "AvenirNextCondensed-Heavy"
        absementLabel.fontSize = labelFontSize
        absementLabel.fontColor = SKColor.white
        var scoreText = String(format: "%.1f", absementScore)
        absementLabel.text = scoreText
        absementLabel.horizontalAlignmentMode = .right
        absementLabel.position = CGPoint(x: bounds.width - absementLabel.frame.size.width / 2 + 10.0,
                                         y: bounds.height - absementLabel.frame.size.height - 15.0)
        
        // absementScoreLabel setup
        absementScoreLabel.zPosition = 1
        absementScoreLabel.fontName = "AvenirNextCondensed-Heavy"
        absementScoreLabel.fontSize = labelFontSize
        absementScoreLabel.fontColor = SKColor.red
        scoreText = String(format: "%.2f", absementScore)
        absementScoreLabel.text = scoreText
        absementScoreLabel.horizontalAlignmentMode = .right
        absementScoreLabel.position = CGPoint(x: absementLabel.position.x,
                                              y: absementLabel.frame.minY - absementScoreLabel.frame.size.height - 10.0 )
        
        // stopButton setup
        stopButton.zPosition = 1
        stopButton.size = CGSize(width: buttonSize, height: buttonSize)
        stopButton.position = CGPoint(x: absementScoreLabel.position.x - stopButton.size.width / 2,
                                      y: absementScoreLabel.frame.minY - stopButton.size.height / 2 - 10.0 )
        
        // centerButton setup
        centerButton.zPosition = 1
        centerButton.size = CGSize(width: buttonSize, height: buttonSize)
        centerButton.position = CGPoint(x: frame.midX, y: frame.midY)

        
        // timeLabel setup
        timeLabel.zPosition = 1
        timeLabel.fontName = "AvenirNextCondensed-Heavy"
        timeLabel.fontSize = labelFontSize
        timeLabel.fontColor = SKColor.white
        let timeText = String(Int(timeLeft))
        timeLabel.text = timeText
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: timeLabel.frame.size.width / 2,
                                     y: bounds.height - timeLabel.frame.size.height - 15.0)
        
        // countDownLabel setup
        countDownLabel.zPosition = 1
        countDownLabel.fontName = "AvenirNextCondensed-Heavy"
        countDownLabel.fontSize = countDownLabelFontSize
        countDownLabel.fontColor = SKColor.white
        let countDownText = String(format: countDownString, countDown)
        countDownLabel.text = countDownText
        countDownLabel.horizontalAlignmentMode = .center
        countDownLabel.position = CGPoint(x: frame.size.width / 2,
                                          y: bounds.height / 3)
        
        // player setup
        player.zPosition = 0
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.strokeColor = SKColor.white
        player.fillColor = SKColor.white
        
        // target setup
        target.zPosition = 0
        target.position = CGPoint(x: frame.midX, y: frame.midY)
        target.strokeColor = SKColor.white
        target.fillColor = SKColor.black
        target.lineWidth = 2.0
        
        // add nodes
        addChild(background)
        addChild(absementLabel)
        addChild(absementScoreLabel)
        addChild(stopButton)
        addChild(centerButton)
        addChild(timeLabel)
        addChild(target)
        addChild(player)
        addChild(countDownLabel)
        
        
        // motion setup
        motionManager.startAccelerometerUpdates()
        
        // audio setup
        if userDefaults.bool(forKey: UserDefaultsKeys.settingsMusicKey) {
            initializeAudio()
        }
        
        // begin countdown
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdown), userInfo: nil, repeats: true)
    }
    
    // MARK: Audio
    private func initializeAudio() {
        guard let engine = AudioEngine(with: "requiem", type: "mp3", options: .loops) else { return }
        self.engine = engine
        self.engine?.setupAudioEngine()
    }
    
    // MARK: Game Progression
    @objc private func updateCountdown() {
        countDown -= 1
        let countDownText = String(format: countDownString, countDown)
        countDownLabel.text = countDownText
        if countDown <= 0 {
            countDownTimer?.invalidate()
            countDownLabel.isHidden = true
            gameActive = true
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateGameTimer), userInfo: nil, repeats: true)
            timerSet = true
        }
    }
    
    @objc private func updateGameTimer() {
        timeLeft -= 1
        timeLabel.text = String(Int(timeLeft))
        if timeLeft <= 0 {
            gameTimer?.invalidate()
            gameOver(completed: true)
        }
    }
    
    private func updateAbsement(_ absement: Double) {
        var convertedAbsement: Double = absement / Double(frame.width)
        let roundedConvertedAbsement = convertedAbsement.rounded(toPlaces: 1)
            
        self.absement = roundedConvertedAbsement
        var scoreText = String(format: "%.1f", self.absement)
        absementLabel.text = scoreText
        
        convertedAbsement = roundedConvertedAbsement / SettingsValues.absementSampleRate
        self.absementScore += convertedAbsement
        scoreText = String(format: "%.2f", self.absementScore)
        absementScoreLabel.text = scoreText
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        // motion update
        if let data = motionManager.accelerometerData {
            self.smoothXAcceleration.update(newValue: data.acceleration.x)
            self.smoothYAcceleration.update(newValue: data.acceleration.y)
            let sensitivity = 5.0 * (userDefaults.float(forKey: UserDefaultsKeys.settingsMotionSensitivityKey) / SettingsValues.sensitivityDefault)
            player.position.x = CGFloat(smoothXAcceleration.value - playerCenterX) * frame.width / 2 * CGFloat(sensitivity) + frame.width / 2
            player.position.y = CGFloat(smoothYAcceleration.value - playerCenterY) * frame.width / 2 * CGFloat(sensitivity) + frame.height / 2
        }
        
        if gameActive {
            let xDist = player.position.x - target.position.x
            let yDist = player.position.y - target.position.y
            let absement = CGFloat(sqrt((xDist * xDist) + (yDist * yDist))) - targetRadius / 2
            if absement >= 0 {
                updateAbsement(Double(absement))
                self.engine?.modifyPitch(with: -Float(absement * 2))
                self.engine?.modifyPlaybackRate(with: Float(1 - (self.absement * 2)))
            }
        }
    }
    
    // MARK: - Game over
    @objc private func gameOver(completed: Bool) {
        gameTimer?.invalidate()
        countDownTimer?.invalidate()
        gameActive = false
        self.engine?.stop()
        if completed {
            self.gameOverDelegate?.sendGameData(game: Workout.Circle.rawValue, duration: Int(exerciseTime), absement: Float(absementScore.rounded(toPlaces: 2)))
        }
        self.gameOverDelegate?.presentPrompt()
    }
    
    func restartGame() {
        timeLeft = self.exerciseTime
        timerSet = false
        timeLabel.text = String(Int(timeLeft))
        
        absement = 0.0
        absementScore = 0.0
        var scoreText = String(format: "%.1f", self.absement)
        absementLabel.text = scoreText
        scoreText = String(format: "%.2f", self.absementScore)
        absementScoreLabel.text = scoreText
        
        self.engine?.restart()
        
        countDown = 10
        let countDownText = String(format: countDownString, countDown)
        countDownLabel.text = countDownText
        countDownLabel.isHidden = false
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdown), userInfo: nil, repeats: true)
    }
    
    private func recenter() {
        // get new recalibrated center position from accelerometerData
        if let data = motionManager.accelerometerData {
            playerCenterX = data.acceleration.x
            playerCenterY = data.acceleration.y
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == stopButton {
                gameOver(completed: false)
            } else if node == centerButton {
                recenter()
            }
        }
    }
}
