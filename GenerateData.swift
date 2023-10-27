//
//  GenerateData.swift
//  TimeSeriesDecrypter
//
//  Created by Ananta Shahane on 08/10/2023.
//

import Foundation

func GenerateData(amplitude : Double, frequency : Double, phase : Double) -> [Double] {
    var timeSeries = Array(repeating: 0.0, count: 100)
    for index in 0..<timeSeries.count {
//        let doubleIndex = Double(index)
        timeSeries[index] +=  Double.random(in: -amplitude...amplitude)
//        timeSeries[index] += ((doubleIndex * amplitude * sin(frequency / 1000 * doubleIndex + phase)) + sqrt(doubleIndex) * Double.random(in: -amplitude...amplitude))
    }
    return timeSeries
}

func MixTimeSeries(timeSeries : [Int : [Double]], weightage : [Int : Double]) -> [Double] {
    var mixedTimeSeries = Array(repeating: Double(0), count: timeSeries.values.first!.count)
    for key in weightage.keys {
        let component = timeSeries[key]!.map({$0 * weightage[key]!})
        mixedTimeSeries = mixedTimeSeries.enumerated().map({$0.element + component[$0.offset]})
    }
    return mixedTimeSeries
    
}



extension Double {
    static func NormalRandom(mu: Double, sigma: Double) -> Double {
        let u1 = Double.random(in: 0...1)
        let u2 = Double.random(in: 0...1)
        
        let z0 = sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
        let randomNumber = z0 * sigma + mu
        
        return randomNumber
    }
}
