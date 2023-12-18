//
//  SKTAudio.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 11/12/23.
//

import AVFoundation

class SKTAudio {
    
    var bgMusic: AVAudioPlayer?
    var soundEffect: AVAudioPlayer?
    
    static func sharedInstance() -> SKTAudio {
        return SKTAudioInstance
    }
    
    func playBGMusic(_ fileNamed: String) {
        if !SKTAudio.musicEnabled { return }
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else { return }
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
            
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        if let bgMusic = bgMusic {
            bgMusic.numberOfLoops = -1
            bgMusic.prepareToPlay()
            bgMusic.play()
        }
    }
    
    func stopBGMusic() {
        if let bgMusic = bgMusic {
            if bgMusic.isPlaying {
                bgMusic.pause()
            }
        }
    }
    
    func resumeBGMusic() {
        if let bgMusic = bgMusic {
            if !bgMusic.isPlaying {
                bgMusic.play()
            }
        }
    }
    
    func playSoundEffect(_ fileNamed: String) {
        guard let url = Bundle.main.url(forResource: fileNamed, withExtension: nil) else { return }
        
        do {
            soundEffect = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            soundEffect = nil
        }
        
        if let soundEffect = soundEffect {
            soundEffect.numberOfLoops = 0
            soundEffect.prepareToPlay()
            soundEffect.play()
        }
    }
    
    static let keyMusic = "keyMusic"
    static var musicEnabled: Bool = {
        return !UserDefaults.standard.bool(forKey: keyMusic)
    }() {
        didSet {
            let value = !musicEnabled
            UserDefaults.standard.set(value, forKey: keyMusic)
            
            if value {
                SKTAudio.sharedInstance().stopBGMusic()
            }
        }
    }
}

private let SKTAudioInstance = SKTAudio()
