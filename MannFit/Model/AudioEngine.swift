//
//  AudioEngineFactory.swift
//  MannFit
//
//  Created by Luis Abraham on 2017-11-17.
//  Copyright © 2017 MannFit Labs. All rights reserved.
//

import AVFoundation

class AudioEngine {
    private let userDefaults: UserDefaults = UserDefaults.standard
    private var engine: AVAudioEngine
    private var audioPlayerNode: AVAudioPlayerNode
    private var unitTimePitch: AVAudioUnitTimePitch
    private var audioBuffer: AVAudioPCMBuffer
    private var bufferOptions: AVAudioPlayerNodeBufferOptions
    
    
    init?(with file: String, type: String, options: AVAudioPlayerNodeBufferOptions) {
        self.engine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        self.unitTimePitch = AVAudioUnitTimePitch()
        
        guard let buffer = AudioEngine.setupFileBuffer(with: file, type: type) else {
            return nil
        }
        
        self.audioBuffer = buffer
        self.bufferOptions = options
    }
    
    func setupAudioEngine() {
        self.engine.attach(self.audioPlayerNode)
        self.engine.attach(self.unitTimePitch)
        
        self.engine.connect(self.audioPlayerNode, to: self.unitTimePitch, format: self.audioBuffer.format)
        self.engine.connect(self.unitTimePitch, to: self.engine.mainMixerNode, format: self.audioBuffer.format)
        
        self.audioPlayerNode.scheduleBuffer(self.audioBuffer, at: nil, options: self.bufferOptions, completionHandler: nil)
        self.audioPlayerNode.volume = userDefaults.float(forKey: UserDefaultsKeys.settingsVolumeKey)
    
        do {
            try self.engine.start()
            self.audioPlayerNode.play()
        } catch {
            fatalError()
        }
    }
    
    func stop() {
        self.audioPlayerNode.stop()
    }
    
    func restart() {
        self.audioPlayerNode.scheduleBuffer(self.audioBuffer, at: nil, options: self.bufferOptions, completionHandler: nil)
        self.audioPlayerNode.play()
    }
    
    func modifyPitch(with value: Float) {
        self.unitTimePitch.pitch = value
        self.audioPlayerNode.scheduleBuffer(self.audioBuffer, at: nil, options: self.bufferOptions, completionHandler: nil)
    }
    
    func modifyPlaybackRate(with rate: Float) {
        self.unitTimePitch.rate = rate
        self.audioPlayerNode.scheduleBuffer(self.audioBuffer, at: nil, options: self.bufferOptions, completionHandler: nil)
    }
    
    private static func setupFileBuffer(with file: String, type: String) -> AVAudioPCMBuffer? {
        let resource = Bundle.main.path(forResource: file, ofType: type)
        
        guard let filePath = resource else {
            return nil
        }
        
        let url = NSURL.fileURL(withPath: filePath)
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = AVAudioFrameCount(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            
            guard let buffer = audioFileBuffer else {
                return nil
            }
            
            try audioFile.read(into: buffer)
            
            return audioFileBuffer
        } catch {
            return nil
        }
    
    }
}
