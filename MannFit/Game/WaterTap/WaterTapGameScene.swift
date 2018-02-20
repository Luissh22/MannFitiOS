//
//  WaterTapGameScene.swift
//  MannFit
//
//  Created by Daniel Till on 2/20/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class WaterTapGameScene: SKScene {
    
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
    private var playerCenterY: Double = 0.0
    
    private let background = SKSpriteNode()
    private let absementLabel = SKLabelNode()
    private let absementScoreLabel = SKLabelNode()
    private var absement: Double = 0
    private var absementScore: Double = 0
    private let stopButton = SKSpriteNode(imageNamed: "menu-icon")
    private let centerButton = SKSpriteNode(imageNamed: "center-icon")
    
    private let water = SKSpriteNode(imageNamed: "WaterAnimationFrame1")
    private let waterFrame1 = SKTexture(imageNamed: "WaterAnimationFrame1")
    private let waterFrame2 = SKTexture(imageNamed: "WaterAnimationFrame2")
    private let waterAnimationKey = "movingWater"
    private let maxWaterWidth: CGFloat = 300.0
    private let pipe = SKSpriteNode(imageNamed: "WaterAnimationTap")
    
    private let countDownLabel = SKLabelNode()
    private let countDownString = "Starting in...%d"
    private var countDown: Int = 10
    private var countDownTimer: Timer?
    
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
        absementLabel.fontSize = 50.0
        absementLabel.fontColor = SKColor.white
        var scoreText = String(absement)
        absementLabel.text = scoreText
        absementLabel.horizontalAlignmentMode = .right
        absementLabel.position = CGPoint(x: bounds.width - absementLabel.frame.size.width / 2 + 10.0,
                                         y: bounds.height - absementLabel.frame.size.height - 15.0)
        
        // absementScoreLabel setup
        absementScoreLabel.zPosition = 1
        absementScoreLabel.fontName = "AvenirNextCondensed-Heavy"
        absementScoreLabel.fontSize = 50.0
        absementScoreLabel.fontColor = SKColor.red
        scoreText = String(absement)
        absementScoreLabel.text = scoreText
        absementScoreLabel.horizontalAlignmentMode = .right
        absementScoreLabel.position = CGPoint(x: absementLabel.position.x,
                                              y: absementLabel.frame.minY - absementScoreLabel.frame.size.height - 10.0 )
        
        // stopButton setup
        stopButton.zPosition = 1
        stopButton.size = CGSize(width: 60.0, height: 60.0)
        stopButton.position = CGPoint(x: absementScoreLabel.position.x - stopButton.size.width / 2,
                                      y: absementScoreLabel.frame.minY - stopButton.size.height / 2 - 10.0 )
        
        // centerButton setup
        centerButton.zPosition = 1
        centerButton.size = CGSize(width: 60.0, height: 60.0)
        centerButton.position = CGPoint(x: absementScoreLabel.position.x - centerButton.size.width / 2,
                                        y: stopButton.frame.minY - centerButton.size.height / 2 - 10.0 )
        
        // timeLabel setup
        timeLabel.zPosition = 1
        timeLabel.fontName = "AvenirNextCondensed-Heavy"
        timeLabel.fontSize = 50.0
        timeLabel.fontColor = SKColor.white
        let timeText = String(Int(timeLeft))
        timeLabel.text = timeText
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: timeLabel.frame.size.width / 2,
                                     y: bounds.height - timeLabel.frame.size.height - 15.0)
        
        // countDownLabel setup
        countDownLabel.zPosition = 1
        countDownLabel.fontName = "AvenirNextCondensed-Heavy"
        countDownLabel.fontSize = 40.0
        countDownLabel.fontColor = SKColor.white
        let countDownText = String(format: countDownString, countDown)
        countDownLabel.text = countDownText
        countDownLabel.horizontalAlignmentMode = .center
        countDownLabel.position = CGPoint(x: frame.size.width / 2,
                                          y: bounds.height / 3)
        
        // water setup
        water.zPosition = 0
        water.size = CGSize(width: maxWaterWidth, height: self.frame.height)
        water.position = CGPoint(x: frame.midX, y: frame.maxY)
        movingWater()
        
        // target setup
        pipe.zPosition = 1
        pipe.position = CGPoint(x: frame.midX, y: frame.maxY)
        
        // add nodes
        addChild(background)
        addChild(absementLabel)
        addChild(absementScoreLabel)
        addChild(stopButton)
        addChild(centerButton)
        addChild(timeLabel)
        addChild(water)
        addChild(pipe)
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
    
    // MARK: Water Animation
    private func movingWater() {
        water.run(SKAction.repeatForever(
            SKAction.animate(with: [waterFrame1, waterFrame2],
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                    withKey:waterAnimationKey)
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
        let convertedAbsement: Double = absement / Double(frame.width)
        let roundedConvertedAbsement = convertedAbsement.rounded(toPlaces: 1)
        self.absement = roundedConvertedAbsement
        var scoreText = String(format: "%.1f", self.absement)
        absementLabel.text = scoreText
        self.absementScore += roundedConvertedAbsement
        scoreText = String(format: "%.1f", self.absementScore)
        absementScoreLabel.text = scoreText
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        // motion update
        var absement: CGFloat = 0.0
        if let data = motionManager.accelerometerData {
            self.smoothYAcceleration.update(newValue: data.acceleration.y)
            let sensitivity = userDefaults.float(forKey: UserDefaultsKeys.settingsMotionSensitivityKey) / SettingsValues.sensitivityDefault
            absement = CGFloat(smoothYAcceleration.value - playerCenterY) * CGFloat(sensitivity)
            let widthScale: CGFloat = absement > 1.0 ? 1.0 : absement
            water.size.width = widthScale * maxWaterWidth
        }
        
        if gameActive {
            if absement >= 0 {
                updateAbsement(Double(absement))
                self.engine?.modifyPitch(with: -Float(absement * 2))
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
            self.gameOverDelegate?.sendGameData(game: "Water Tap", duration: Int(exerciseTime), absement: Float(absementScore))
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
        scoreText = String(format: "%.1f", self.absementScore)
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
