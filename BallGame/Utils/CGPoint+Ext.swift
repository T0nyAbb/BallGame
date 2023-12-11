//
//  CGPoint+Ext.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 07/12/23.
//

import CoreGraphics

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func +=(left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -=(left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *=(point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /=(point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}
