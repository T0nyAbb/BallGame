//
//  Types.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 10/12/23.
//

import Foundation

struct PhysicsCategory {
    static let Player: UInt32 =     0b1
    static let Block: UInt32 =      0b10
    static let Obstacle: UInt32 =   0b100
    static let Ground: UInt32 =     0b1000
    static let Coin: UInt32 =       0b10000
    static let Santa: UInt32 =      0b100000
}
