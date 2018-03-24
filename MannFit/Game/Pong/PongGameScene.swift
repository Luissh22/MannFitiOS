//
//  PongGameScene.swift
//  MannFit
//
//  Created by Daniel Till on 10/3/18.
//  Copyright © 2018 MannFit Labs. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class PongGameScene: SKScene {

    // MARK: Initilization
    private let motionManager = CMMotionManager()
    weak var gameOverDelegate: GameOverDelegate?
    private let userDefaults: UserDefaults = UserDefaults.standard
    var engine: AudioEngine?
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
    
    // MARK: Properties
    enum ColliderType: UInt32 {
        case Paddle = 1
        case Ball = 2
    }
    
    // player center calibration
    private var playerCenterX: Double = 0.0
    
    private let background = SKSpriteNode()
    private let absementLabel = SKLabelNode()
    private let absementScoreLabel = SKLabelNode()
    private var absement: Double = 0
    private var absementScore: Double = 0
    private let stopButton = SKSpriteNode(imageNamed: "menu-icon")
    private let centerButton = SKSpriteNode(imageNamed: "center-icon")
    
    private let paddleHeight: CGFloat = 30.0
    private let paddleWidth: CGFloat = 100.0
    private let markerWidth: CGFloat = 5.0
    private let ballRadius: CGFloat = 15.0
    
    private lazy var playerPaddle = {
        return SKShapeNode(rectOf: CGSize(width: paddleWidth, height: paddleHeight))
    }()
    private lazy var playerMarker = {
        return SKShapeNode(rectOf: CGSize(width: markerWidth, height: paddleHeight))
    }()
    private lazy var enemyPaddle = {
        return SKShapeNode(rectOf: CGSize(width: paddleWidth, height: paddleHeight))
    }()
    private lazy var enemyMarker = {
        return SKShapeNode(rectOf: CGSize(width: markerWidth, height: paddleHeight))
    }()
    private lazy var ball = {
        return SKShapeNode(circleOfRadius: ballRadius)
    }()
    private let ballLine = SKShapeNode()
    
    private let countDownLabel = SKLabelNode()
    private let countDownString = "Starting in...%d"
    private var countDown: Int = 10
    private var countDownTimer: Timer?
    
    private var moveThroughBallTop: Bool = false
    private var moveThroughBallBottom: Bool = false
    
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
    
    override func didMove(to view: SKView) {
        // background setup
        let bounds:CGSize = frame.size
        backgroundColor = SKColor.black
        background.zPosition = -10.0
        background.scale(to: frame.size)
        
        // absementLabel setup
        absementLabel.zPosition = 5
        absementLabel.fontName = "AvenirNextCondensed-Heavy"
        absementLabel.fontSize = labelFontSize
        absementLabel.fontColor = SKColor.white
        var scoreText = String(format: "%.1f", absementScore)
        absementLabel.text = scoreText
        absementLabel.horizontalAlignmentMode = .right
        absementLabel.position = CGPoint(x: bounds.width - absementLabel.frame.size.width / 2 + 10.0,
                                         y: bounds.height - absementLabel.frame.size.height - 15.0)
        
        // absementScoreLabel setup
        absementScoreLabel.zPosition = 5
        absementScoreLabel.fontName = "AvenirNextCondensed-Heavy"
        absementScoreLabel.fontSize = labelFontSize
        absementScoreLabel.fontColor = SKColor.red
        scoreText = String(format: "%.2f", absementScore)
        absementScoreLabel.text = scoreText
        absementScoreLabel.horizontalAlignmentMode = .right
        absementScoreLabel.position = CGPoint(x: absementLabel.position.x,
                                              y: absementLabel.frame.minY - absementScoreLabel.frame.size.height - 10.0 )
        
        // stopButton setup
        stopButton.zPosition = 5
        stopButton.size = CGSize(width: buttonSize, height: buttonSize)
        stopButton.position = CGPoint(x: absementScoreLabel.position.x - stopButton.size.width / 2,
                                      y: absementScoreLabel.frame.minY - stopButton.size.height / 2 - 10.0 )
        
        // centerButton setup
        centerButton.zPosition = 5
        centerButton.size = CGSize(width: buttonSize, height: buttonSize)
        centerButton.position = CGPoint(x: absementScoreLabel.position.x - centerButton.size.width / 2,
                                        y: stopButton.frame.minY - centerButton.size.height / 2 - 10.0 )
        
        // timeLabel setup
        timeLabel.zPosition = 5
        timeLabel.fontName = "AvenirNextCondensed-Heavy"
        timeLabel.fontSize = labelFontSize
        timeLabel.fontColor = SKColor.white
        let timeText = String(Int(timeLeft))
        timeLabel.text = timeText
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: timeLabel.frame.size.width / 2,
                                     y: bounds.height - timeLabel.frame.size.height - 15.0)
        
        // countDownLabel setup
        countDownLabel.zPosition = 4
        countDownLabel.fontName = "AvenirNextCondensed-Heavy"
        countDownLabel.fontSize = countDownLabelFontSize
        countDownLabel.fontColor = SKColor.white
        let countDownText = String(format: countDownString, countDown)
        countDownLabel.text = countDownText
        countDownLabel.horizontalAlignmentMode = .center
        countDownLabel.position = CGPoint(x: frame.size.width / 2,
                                          y: bounds.height / 3)
        
        // Player setup
        let paddleSize = CGSize(width: paddleWidth, height: paddleHeight)
        playerPaddle.zPosition = 0
        playerPaddle.position = CGPoint(x: frame.midX, y: 100)
        playerPaddle.fillColor = UIColor.white
        playerPaddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        playerPaddle.physicsBody?.isDynamic = false
        playerPaddle.physicsBody?.affectedByGravity = false
        playerPaddle.physicsBody?.allowsRotation = false
        playerPaddle.physicsBody?.friction = 0
        playerPaddle.physicsBody?.restitution = 0
        playerPaddle.physicsBody?.categoryBitMask = ColliderType.Paddle.rawValue
        playerPaddle.physicsBody?.collisionBitMask = ColliderType.Ball.rawValue
        playerPaddle.physicsBody?.contactTestBitMask = ColliderType.Ball.rawValue
        
        // Player marker setup
        playerMarker.zPosition = 1
        playerMarker.fillColor = UIColor.blue
        
        // Enemy setup
        enemyPaddle.zPosition = 0
        enemyPaddle.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        enemyPaddle.fillColor = UIColor.white
        enemyPaddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        enemyPaddle.physicsBody?.isDynamic = false
        enemyPaddle.physicsBody?.affectedByGravity = false
        enemyPaddle.physicsBody?.allowsRotation = false
        enemyPaddle.physicsBody?.friction = 0
        enemyPaddle.physicsBody?.restitution = 0
        enemyPaddle.physicsBody?.categoryBitMask = ColliderType.Paddle.rawValue
        enemyPaddle.physicsBody?.collisionBitMask = ColliderType.Ball.rawValue
        enemyPaddle.physicsBody?.contactTestBitMask = ColliderType.Ball.rawValue
        
        // Enemy marker setup
        enemyMarker.zPosition = 1
        enemyMarker.fillColor = UIColor.blue
        
        // Ball setup
        ball.zPosition = 0
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.fillColor = UIColor.white
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.categoryBitMask = ColliderType.Ball.rawValue
        ball.physicsBody?.collisionBitMask = ColliderType.Paddle.rawValue
        ball.physicsBody?.contactTestBitMask = ColliderType.Paddle.rawValue
        
        // Ball Line setup
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 2 * self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        ballLine.path = path.cgPath
        ballLine.strokeColor = UIColor.red
        ballLine.lineWidth = 2
        ballLine.zPosition = 2
        ballLine.position.y = -self.frame.height
        
        // game border
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        // add nodes
        addChild(background)
        addChild(absementLabel)
        addChild(absementScoreLabel)
        addChild(stopButton)
        addChild(centerButton)
        addChild(timeLabel)
        addChild(countDownLabel)
        addChild(playerPaddle)
        addChild(enemyPaddle)
        addChild(ball)
        ball.addChild(ballLine)
        playerPaddle.addChild(playerMarker)
        enemyPaddle.addChild(enemyMarker)
        
        // motion setup
        motionManager.startAccelerometerUpdates()
        
        // begin countdown
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdown), userInfo: nil, repeats: true)
        
        // audio setup
        if userDefaults.bool(forKey: UserDefaultsKeys.settingsMusicKey) {
            initializeAudio()
        }
    }
    
    // MARK: Audio
    private func initializeAudio() {
        guard let engine = AudioEngine(with: "requiem", type: "mp3", options: .loops) else { return }
        self.engine = engine
        self.engine?.setupAudioEngine()
    }
    
    override func didSimulatePhysics() {
        
        // motion update
        if let data = motionManager.accelerometerData {
            self.smoothXAcceleration.update(newValue: data.acceleration.x)
            let sensitivity = 2.0 * (userDefaults.float(forKey: UserDefaultsKeys.settingsMotionSensitivityKey) / SettingsValues.sensitivityDefault)
            playerPaddle.position.x = CGFloat(smoothXAcceleration.value - playerCenterX) * frame.width / 2 * CGFloat(sensitivity) + frame.width / 2
        }
        
        if gameActive {
            // move enemyPaddle
            enemyPaddle.position.x = ball.position.x
            
            // handle absement difference
            let xDifference = abs(playerPaddle.position.x - ball.position.x)
            updateAbsement(Double(xDifference))
            self.engine?.modifyPitch(with: -Float(xDifference * 2))
            self.engine?.modifyPlaybackRate(with: Float(1 - (self.absement * 2)))
        }
        
        // handle ball below player paddle
        if ball.position.y < playerPaddle.position.y + paddleHeight / 2 {
            playerPaddle.physicsBody?.categoryBitMask = 0
            moveThroughBallBottom = true
        }
        
        if moveThroughBallBottom && ball.position.y - ballRadius > playerPaddle.position.y + paddleHeight / 2 {
            playerPaddle.physicsBody?.categoryBitMask = ColliderType.Paddle.rawValue
            moveThroughBallBottom = false
        }
        
        // handle ball above enemy paddle
        if ball.position.y > enemyPaddle.position.y - paddleHeight / 2 {
            enemyPaddle.physicsBody?.categoryBitMask = 0
            moveThroughBallTop = true
        }
        
        if moveThroughBallTop && ball.position.y + ballRadius < enemyPaddle.position.y -  paddleHeight / 2{
            enemyPaddle.physicsBody?.categoryBitMask = ColliderType.Paddle.rawValue
            moveThroughBallTop = false
        }
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
            ball.physicsBody?.applyImpulse(CGVector(dx: 2, dy: -2))
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
    
    // MARK: - Game over
    @objc private func gameOver(completed: Bool) {
        gameTimer?.invalidate()
        countDownTimer?.invalidate()
        
        // stop ball movement
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        gameActive = false
        self.engine?.stop()
        if completed {
            self.gameOverDelegate?.sendGameData(game: Workout.Pong.rawValue, duration: Int(exerciseTime), absement: Float(absementScore.rounded(toPlaces: 2)))
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
        
        // reset ball and paddle position
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        enemyPaddle.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        
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
