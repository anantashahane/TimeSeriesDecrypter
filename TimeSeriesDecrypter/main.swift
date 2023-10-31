//
//  main.swift
//  TimeSeriesDecrypter
//
//  Created by Ananta Shahane on 08/10/2023.
//

import Foundation

struct TimeSeriesData : Encodable {
    let originalTimeSeries : [Double]
    let combinedTimeSeries : [Double]
    let optimal : Coordinate
    let progression : [Coordinate]
    let error : [Double]
}

struct Coordinate : Encodable {
    let coodrinates : [Int : Double]
}

func SaveFile(data : Data) {
    let fileHandles = FileManager()
    let condition = fileHandles.createFile(atPath: "\(fileHandles.currentDirectoryPath)/data.json", contents: data)
    let string = condition ? "Saved file at \(fileHandles.currentDirectoryPath)" : "Failed to save in \(fileHandles.currentDirectoryPath)"
    print(string)
}

func GenerateJsonData(original : [Double], combined : [Double], optimal : Coordinate, progression : [Coordinate], error : [Double]) -> Data? {
    let encode = JSONEncoder()
    let timeSeriesData = TimeSeriesData(originalTimeSeries: original, combinedTimeSeries: combined, optimal: optimal, progression: progression, error: error)
    let data = try? encode.encode(timeSeriesData)
    return data
}

let ea = EvolutionaryAlgorithm(parentPopulationSize: 10, offspringPopulationSize: 10, numberOfWavelets: 10)

let (originalData, combinedData) = ea.GenerateAlgorithm(iterationCount: 10000)
if let data = GenerateJsonData(original: originalData, combined: combinedData, optimal: Coordinate(coodrinates: ea.optimal), progression: ea.progression.map({Coordinate(coodrinates: $0)}), error: ea.errorProgression) {
    print("Saving data.")
    SaveFile(data: data)
}
