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
}

func SaveFile(data : Data) {
    let fileHandles = FileManager()
    let condition = fileHandles.createFile(atPath: "\(fileHandles.currentDirectoryPath)/data.json", contents: data)
    let string = condition ? "Saved file at \(fileHandles.currentDirectoryPath)" : "Failed to save in \(fileHandles.currentDirectoryPath)"
    print(string)
}

func GenerateJsonData(original : [Double], combined : [Double]) -> Data? {
    let encode = JSONEncoder()
    let timeSeriesData = TimeSeriesData(originalTimeSeries: original, combinedTimeSeries: combined)
    let data = try? encode.encode(timeSeriesData)
    return data
}

let ea = EvolutionaryAlgorithm(parentPopulationSize: 10, offspringPopulationSize: 10)
let (originalData, combinedData) = ea.GenerateAlgorithm()
if let data = GenerateJsonData(original: originalData, combined: combinedData) {
    print("Saving data.")
    SaveFile(data: data)
}
