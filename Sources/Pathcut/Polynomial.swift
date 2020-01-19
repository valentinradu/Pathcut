//
//  File.swift
//  
//
//  Created by Valentin Radu on 17/01/2020.
//

import Foundation


func linearSolve(a: Double, b: Double) -> [Double] {
    if a == 0 {
        return []
    }
    else {
        return [-b/a]
    }
}

func quadraticSolve(a: Double, b: Double, c: Double) -> [Double] {
    if a == 0 { return linearSolve(a: b, b: c) }

    let d = b*b - 4*a*c

    if d > 0 {
        let x1 = (-b + sqrt(d))/(2*a)
        let x2 = (-b - sqrt(d))/(2*a)
        return [x1, x2]
    }
    else if d == 0 {
        let x = -b/(2*a)
        return [x, x]
    }
    else {
        return []
    }
}

func cubicSolve(a: Double, b: Double, c: Double, d: Double) -> [Double] {
    if a == 0 { return quadraticSolve(a: b, b: c, c: d) }

    let p = b/a
    let q = c/a
    let r = d/a
    let u = q - pow(p, 2)/3
    let v = r - p*q/3 + 2*pow(p, 3)/27

    let M = Double.greatestFiniteMagnitude
    if abs(p) > 27 * pow(M, 1/3) {
        return [-p]
    }
    else if abs(v) > pow(M, 1/2) {
        return [pow(v, 1/3)]
    }
    else if abs(u) > 3 * pow(M, 1/3) {
        return [pow(4, 1/3) * u / 3]
    }

    let j = 4*pow(u/3, 3) + pow(v, 2)

    if j >= 0 {
        let w = pow(j, 1/2)
        let y = (u/3) * pow(2/(w + v), 1/3) - pow((w + v)/2, 1/3) - p/3
        return [y]
    }
    else {
        let s = pow((-u/3), 1/2)
        let t = -v/(2 * pow(s, 3))
        let k = acos(t)/3

        let y1 = 2 * s * cos(k) - p/3
        let y2 = s * (-cos(k) + pow(3, 1/2) * sin(k)) - p/3
        let y3 = s * (-cos(k) - pow(3, 1/2) * sin(k)) - p/3
        return [y1, y2, y3]
    }
}
