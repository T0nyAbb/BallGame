//
//  ScoreGenerator.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 10/12/23.
//

import Foundation

class ScoreGenerator {
    static let sharedInstance = ScoreGenerator()
    private init() {}
    
    static let keyHighScore = "keyHighScore"
    static let keyScore = "keyScore"
    
    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }
    
    func getScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
    
    func setHighScore(_ highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: ScoreGenerator.keyHighScore)
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreGenerator.keyHighScore)
    }
    
    
    
}
