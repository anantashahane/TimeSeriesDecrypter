//
//  EvolutionaryAlgorithm.swift
//  TimeSeriesDecrypter
//
//  Created by Ananta Shahane on 08/10/2023.
//

import Foundation

struct Individual {
    var weightage : [Int: Double]
    var mutationAmplitude : [Int: Double]
    var mutationDirection : [Int : Double]
    var error : Double?
    
    init(numberofSignals: Int) {
        weightage = [Int: Double]()
        mutationAmplitude = [Int: Double]()
        mutationDirection = [Int : Double]()
        for i in 1...numberofSignals {
            weightage[i] = Double.random(in: 0...1)
            mutationAmplitude[i] = 1
            mutationDirection[i] = 0
        }
    }
}

class EvolutionaryAlgorithm {
    let data : [Double]
    var baseTimeSeries : [Int : [Double]]
    let subtimeSeriesCount : Int
    let offspringPopulationSize : Int
    let parentPopulationSize : Int
    
    //Variables
    var parentPopulation = [Individual]()
    var offspringPopulation = [Individual]()
    var recombinedEntity : Individual
    init(parentPopulationSize : Int, offspringPopulationSize : Int) {
        baseTimeSeries = [:]
        var weightage = [Int : Double]()
        for i in 1...5 {
            baseTimeSeries[i] = GenerateData(amplitude: Double.random(in: 1...10), frequency: Double.random(in: 1...20), phase: Double.random(in: 1...10_000))
            weightage[i] = Double.random(in: 1...100)
        }
        data = MixTimeSeries(timeSeries: baseTimeSeries, weightage: weightage)
        recombinedEntity = Individual(numberofSignals: baseTimeSeries.count)
        subtimeSeriesCount = 3
        self.parentPopulationSize = parentPopulationSize
        self.offspringPopulationSize = offspringPopulationSize
    }
    
    func Initialise() {
        for _ in 0..<parentPopulationSize {
            let individual = Individual(numberofSignals: baseTimeSeries.count)
            parentPopulation.append(individual)
        }
    }
    
    func Evaluate(evaluateParentPopulation : Bool) {
        if evaluateParentPopulation {
            for (parentNumber, parent) in parentPopulation.enumerated() {
                let timeSeries = MixTimeSeries(timeSeries: baseTimeSeries, weightage: parent.weightage)
                var error : Double = 0
                for (index, _) in timeSeries.enumerated() {
                    error += abs(timeSeries[index] - data[index])
                }
                parentPopulation[parentNumber].error = error / Double(timeSeries.count)
            }
        } else {
            for (offspringNumber, offspring) in offspringPopulation.enumerated() {
                let timeSeries = MixTimeSeries(timeSeries: baseTimeSeries, weightage: offspring.weightage)
                var error : Double = 0
                for (index, _) in timeSeries.enumerated() {
                    error += abs(timeSeries[index] - data[index])
                }
                offspringPopulation[offspringNumber].error = error / Double(timeSeries.count)
            }
            let timeSeries = MixTimeSeries(timeSeries: baseTimeSeries, weightage: recombinedEntity.weightage)
            var error = 0.0
            for(index, _) in timeSeries.enumerated() {
                error += abs(timeSeries[index] - data[index])
            }
            recombinedEntity.error = error
        }
    }
    
    func Recombine() {
        for key in parentPopulation[0].weightage.keys {
            recombinedEntity.weightage[key] = parentPopulation.map({$0.weightage[key] ?? 1}).reduce(0, +) / Double(parentPopulation.count)
            recombinedEntity.mutationDirection[key] = parentPopulation.map({$0.mutationDirection[key] ?? 1}).reduce(0, +) / Double(parentPopulation.count)
            recombinedEntity.mutationAmplitude[key] = parentPopulation.map({$0.mutationAmplitude[key] ?? 1}).reduce(0, +) / Double(parentPopulation.count)
        }
    }
    
    func Mutation() -> Individual {
        var returnIndividual = recombinedEntity
        // Mutate Amplitude
        for key in returnIndividual.weightage.keys {
//            if Int.random(in: 1...100) > 10 {
//                returnIndividual.mutationDirection[key] = 0
//                returnIndividual.mutationAmplitude[key] = 1
//            }
            returnIndividual.mutationDirection[key] = Double.NormalRandom(mu: returnIndividual.mutationDirection[key] ?? 0, sigma: 1)
            returnIndividual.mutationAmplitude[key]! *= pow(2.71, returnIndividual.mutationDirection[key] ?? 0)
            let mutation = returnIndividual.weightage[key]! * returnIndividual.mutationAmplitude[key]!
            returnIndividual.weightage[key] = mutation
        }
        return returnIndividual
    }
    
    func Mutate() {
        offspringPopulation = []
        for _ in 1...offspringPopulationSize {
            offspringPopulation.append(Mutation())
        }
    }
    
    func Selection() {
        let population = (parentPopulation + offspringPopulation + [recombinedEntity]).sorted(by: {
            ($0.error ?? 0) < ($1.error ?? 0)
        })
        offspringPopulation = []
        parentPopulation = Array(population[0..<parentPopulationSize])
    }
    
    func GenerateAlgorithm() -> ([Double], [Double]) {
        Initialise()
        var bestSolution  = Individual(numberofSignals: 3)
        Evaluate(evaluateParentPopulation: true)
        for iteration in 1...50000 {
            Recombine()
            Mutate()
            Evaluate(evaluateParentPopulation: false)
            Selection()
            if let bstSolution = parentPopulation.sorted(by: {$0.error ?? Double.infinity > $1.error ?? Double.infinity}).first {
                bestSolution = bstSolution
                print("Iteration \(iteration): Min Loss \(bestSolution.error!), best fit \(bestSolution.weightage.sorted(by: {$0.key < $1.key}).map({$0.value})).")
            }
        }
        
        return (data, MixTimeSeries(timeSeries: baseTimeSeries, weightage: bestSolution.weightage))
    }
}
