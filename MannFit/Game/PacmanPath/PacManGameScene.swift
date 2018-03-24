import SpriteKit
import GameplayKit
import CoreMotion


class PacManGameScene: SKScene, GameTimeCompliant {
    
    // MARK: Initilization
    private enum ColliderType: UInt32 {
        case player = 1
        case food = 2
        case line = 4
        case wall = 8
    }
    
    private let motionManager = CMMotionManager()
    private let userDefaults: UserDefaults = UserDefaults.standard
    var engine: AudioEngine?
    weak var gameOverDelegate: GameOverDelegate?
    
    private var gameTimer: Timer?
    private var gameActive: Bool = true
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
    
    private let background = SKSpriteNode()
    private let absementLabel = SKLabelNode()
    private let absementScoreLabel = SKLabelNode()
    private var absement: Double = 0
    private var absementScore: Double = 0
    private let stopButton = SKSpriteNode(imageNamed: "menu-icon")
    private let centerButton = SKSpriteNode(imageNamed: "center-icon")

    private let wall1 = SKSpriteNode()
    private let wall2 = SKSpriteNode()
    private let wall3 = SKSpriteNode()
    private let player = SKSpriteNode(imageNamed: "pacmanPlayerOpen")
    private var playerRelativeStartYPosition: CGFloat = 50.0
    private lazy var playerRelativeYPosition: CGFloat = {
        return playerRelativeStartYPosition
    }()
    private let playerFrame1 = SKTexture(imageNamed: "pacmanPlayerOpen")
    private let playerFrame2 = SKTexture(imageNamed: "pacmanPlayerClose")
    private let pacmanAnimationKey = "eatingPacman"
    
    private var balancePath: BalancePath?
    private var balancePathNode: SKShapeNode?
    private let balancePathStartY: CGFloat = 500.0
    private let balancePathLength: CGFloat = 600.0
    private let balancePathAmplification: CGFloat = 0.8
    
    private lazy var labelFontSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 40.0 : 50.0
    }()
    private lazy var buttonSize: CGFloat = {
        return UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? 50.0 : 60.0
    }()
    
    var smoothXAcceleration = LowPassFilterSignal(value: 0, timeConstant: 0.90)
    
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
        centerButton.position = CGPoint(x: absementScoreLabel.position.x - centerButton.size.width / 2,
                                        y: stopButton.frame.minY - centerButton.size.height / 2 - 10.0 )
        
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
        
        // player setup
        player.zPosition = 0
        player.scale(to: CGSize(width: 10.0, height: 10.0))
        player.position = CGPoint(x: bounds.width / 2, y: playerRelativeYPosition)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = ColliderType.player.rawValue
        player.physicsBody?.collisionBitMask = ColliderType.wall.rawValue + ColliderType.food.rawValue
        eatingPacman()
        
        // wall setup
        wall1.zPosition = 0
        var wallPosition: CGPoint = CGPoint(x: bounds.width / 2, y: 0)
        var wallSize: CGSize = CGSize(width: bounds.width, height: 1)
        wall1.physicsBody = SKPhysicsBody(rectangleOf: wallSize, center: wallPosition)
        wall1.physicsBody?.isDynamic = false
        wall1.physicsBody?.categoryBitMask = ColliderType.wall.rawValue
        
        wall2.zPosition = 0
        wallPosition = CGPoint(x: 0, y: bounds.height / 2)
        wallSize = CGSize(width: 1, height: bounds.height)
        wall2.physicsBody = SKPhysicsBody(rectangleOf: wallSize, center: wallPosition)
        wall2.physicsBody?.isDynamic = false
        wall2.physicsBody?.categoryBitMask = ColliderType.wall.rawValue
        
        wall3.zPosition = 0
        wallPosition = CGPoint(x: bounds.width, y: bounds.height / 2)
        wallSize = CGSize(width: 1, height: bounds.height)
        wall3.physicsBody = SKPhysicsBody(rectangleOf: wallSize, center: wallPosition)
        wall3.physicsBody?.isDynamic = false
        wall3.physicsBody?.categoryBitMask = ColliderType.wall.rawValue
        
        // add nodes
        addChild(background)
        addChild(absementLabel)
        addChild(absementScoreLabel)
        addChild(stopButton)
        addChild(centerButton)
        addChild(timeLabel)
        addChild(wall1)
        addChild(wall2)
        addChild(wall3)
        addChild(player)
        
        // initiate balance path
        initializeBalancePath()
        
        // motion setup
        motionManager.startAccelerometerUpdates()
        
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
    
    // MARK: BalancePath
    private func initializeBalancePath() {
        balancePath = BalancePath(origin: CGPoint(x: self.frame.width / 2, y: balancePathStartY),
                                  length: balancePathLength,
                                  bounds: self.frame.size,
                                  distanceToBottom: playerRelativeStartYPosition)
        balancePathNode = SKShapeNode()
        if let balancePath = balancePath, let balancePathNode = balancePathNode {
            balancePathNode.zPosition = 0
            balancePathNode.path = balancePath.path
            balancePathNode.lineWidth = 5.0
            balancePathNode.strokeColor = UIColor.white
            balancePathNode.physicsBody = SKPhysicsBody(edgeChainFrom: balancePath.path)
            balancePathNode.physicsBody?.isDynamic = false
            addChild(balancePathNode)
        }
    }
    
    // MARK: Pacman Animations
    private func eatingPacman() {
        player.run(SKAction.repeatForever(
            SKAction.animate(with: [playerFrame1, playerFrame2],
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
                   withKey:pacmanAnimationKey)
    }
    
    // MARK: Game Progression
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
        
        // start timer when player begins balance path
        if playerRelativeYPosition >= balancePathStartY && !timerSet {
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateGameTimer), userInfo: nil, repeats: true)
            timerSet = true
        }
        
        // motion update
        if let data = motionManager.accelerometerData {
            self.smoothXAcceleration.update(newValue: data.acceleration.x)
            let sensitivity = 5.0 * (userDefaults.float(forKey: UserDefaultsKeys.settingsMotionSensitivityKey) / SettingsValues.sensitivityDefault)
            player.position.x = CGFloat(smoothXAcceleration.value - playerCenterX) * frame.width / 2 * CGFloat(sensitivity) + frame.width / 2
        }
        
        if gameActive {
            var xDifference: CGFloat = 0.0
            if let balancePath = balancePath, let balancePathNode = balancePathNode {
                // traverse path
                balancePathNode.position.y -= 1
                playerRelativeYPosition += 1
                
                // check path difference
                let relativePlayerPosition = CGPoint(x: player.position.x, y: playerRelativeYPosition)
                xDifference = balancePath.differenceFromPathPoint(relativePlayerPosition)
                
                // extend path
                if balancePath.totalLength - playerRelativeYPosition <= frame.height {
                    balancePath.appendBalancePathWithRandomSegment(length: balancePathLength, amplification: balancePathAmplification)
                }
                balancePathNode.path = balancePath.path
            }
            updateAbsement(Double(xDifference))
            self.engine?.modifyPitch(with: -Float(xDifference * 2))
            self.engine?.modifyPlaybackRate(with: Float(1 - (self.absement * 2)))
        }
    }
    
    // MARK: - Game over
    @objc private func gameOver(completed: Bool) {
        gameTimer?.invalidate()
        gameActive = false
        self.engine?.stop()
        player.removeAction(forKey: pacmanAnimationKey)
        if completed {
            self.gameOverDelegate?.sendGameData(game: "PacMan", duration: Int(inputTime), absement: Float(absementScore.rounded(toPlaces: 2)))
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
        
        playerRelativeYPosition = playerRelativeStartYPosition
        balancePathNode?.removeFromParent()
        balancePathNode = nil
        balancePath = nil
        initializeBalancePath()
        
        self.engine?.restart()
        
        eatingPacman()
        gameActive = true
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
