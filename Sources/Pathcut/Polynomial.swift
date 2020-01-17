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

    let a1 = b/a
    let a2 = c/a
    let a3 = d/a

    let q = (3*a2 - pow(a1, 2))/9
    let r = (9*a1*a2 - 27*a3 - 2*pow(a1, 3)) / 54

    let d = pow(q, 3) + pow(r, 2)

    if d <= 0 {
        let theta = acos(r/sqrt(-pow(q, 3)))
        let x1 = 2*sqrt(-q)*cos((1/3)*theta) - (1/3)*a1
        let x2 = 2*sqrt(-q)*cos((1/3)*theta + 2*Double.pi/3) - (1/3)*a1
        let x3 = 2*sqrt(-q)*cos((1/3)*theta + 4*Double.pi/3) - (1/3)*a1
        return [x1, x2, x3]
    }
    else {
        return []
    }
}
