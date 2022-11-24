//
//  ProblemStatementCellModel.swift
//  Themis
//
//  Created by Florian Huber on 14.11.22.
//

// swiftlint:disable line_length

import Foundation
import SwiftUI

class ProblemStatementCellViewModel: ObservableObject {

    static func splitString(_ problemStatement: String) -> [String] {
        return problemStatement
            .components(separatedBy: "\n")
    }

    static func convertString(_ problemStatement: String) -> String {
        return problemStatement
            .replacingOccurrences(of: "[task][", with: "") // to remove symbol
            .replacingOccurrences(of: "](.*())", with: "", options: .regularExpression) // to remove tests
            .replacingOccurrences(of: "@startuml.*@enduml", with: "", options: .regularExpression) // to remove UML diagram, does not work....
    }

    static let mockData = "# Sorting with the Strategy Pattern\n\nIn this exercise, we want to implement sorting algorithms and choose them based on runtime specific variables.\n\n### Part 1: Sorting\n\nFirst, we need to implement two sorting algorithms, in this case `MergeSort` and `BubbleSort`.\n\n**You have the following tasks:**\n\n1. [task][Implement Bubble Sort](testBubbleSort())\nImplement the method `performSort(List<Date>)` in the class `BubbleSort`. Make sure to follow the Bubble Sort algorithm exactly.\n\n2. [task][Implement Merge Sort](testMergeSort())\nImplement the method `performSort(List<Date>)` in the class `MergeSort`. Make sure to follow the Merge Sort algorithm exactly.\n\n### Part 2: Strategy Pattern\n\nWe want the application to apply different algorithms for sorting a `List` of `Date` objects.\nUse the strategy pattern to select the right sorting algorithm at runtime.\n\n**You have the following tasks:**\n\n1. [task][SortStrategy Interface](testClass[SortStrategy],testMethods[SortStrategy])\nCreate a `SortStrategy` interface and adjust the sorting algorithms so that they implement this interface.\n\n2. [task][Context Class](testAttributes[Context],testMethods[Context])\nCreate and implement a `Context` class following the below class diagram\n\n3. [task][Context Policy](testConstructors[Policy],testAttributes[Policy],testMethods[Policy])\nCreate and implement a `Policy` class following the below class diagram with a simple configuration mechanism:\n\n  1. [task][Select MergeSort](testClass[MergeSort],testUseMergeSortForBigList())\n  Select `MergeSort` when the List has more than 10 dates.\n\n  2. [task][Select BubbleSort](testClass[BubbleSort],testUseBubbleSortForSmallList())\n  Select `BubbleSort` when the List has less or equal 10 dates.\n\n4. Complete the `Client` class which demonstrates switching between two strategies at runtime.\n\n@startuml\n\nclass Client {\n}\n\nclass Policy {\n <color:testsColor(testMethods[Policy])>+configure()</color>\n}\n\nclass Context {\n <color:testsColor(testAttributes[Context])>-dates: List<Date></color>\n <color:testsColor(testMethods[Context])>+sort()</color>\n}\n\ninterface SortStrategy {\n <color:testsColor(testMethods[SortStrategy])>+performSort(List<Date>)</color>\n}\n\nclass BubbleSort {\n <color:testsColor(testBubbleSort)>+performSort(List<Date>)</color>\n}\n\nclass MergeSort {\n <color:testsColor(testMergeSort)>+performSort(List<Date>)</color>\n}\n\nMergeSort -up-|> SortStrategy #testsColor(testClass[MergeSort])\nBubbleSort -up-|> SortStrategy #testsColor(testClass[BubbleSort])\nPolicy -right-> Context #testsColor(testAttributes[Policy]): context\nContext -right-> SortStrategy #testsColor(testAttributes[Context]): sortAlgorithm\nClient .down.> Policy\nClient .down.> Context\n\nhide empty fields\nhide empty methods\n\n@enduml\n\n\n### Part 3: Optional Challenges\n\n(These are not tested)\n\n1. Create a new class `QuickSort` that implements `SortStrategy` and implement the Quick Sort algorithm.\n\n2. Make the method `performSort(List<Dates>)` generic, so that other objects can also be sorted by the same method.\n**Hint:** Have a look at Java Generics and the interface `Comparable`.\n\n3. Think about a useful decision in `Policy` when to use the new `QuickSort` algorithm.\n"
}