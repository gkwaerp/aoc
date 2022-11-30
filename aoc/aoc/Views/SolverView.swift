//
//  SolverView.swift
//  aoc
//
//  Created by Geir-Kåre S. Wærp on 30/11/2022.
//

import Foundation
import SwiftUI

// MARK: - UI
struct SolverView: View {
    let solveState: SolveState
    let buttonText: String
    let action: () -> Void

    var body: some View {
        let progressViewOpacity = solveState.progressViewOpacity
        let textOpacity = solveState.textOpacity
        let buttonOpacity = solveState.buttonOpacity

        ZStack {
            ProgressView()
                .opacity(progressViewOpacity)
            Text(solveState.text)
                .opacity(textOpacity)
            Button(action: action, label: {
                Text(buttonText)
            })
            .opacity(buttonOpacity)
            .disabled(solveState.buttonIsDisabled)
        }
        .animation(.default, value: progressViewOpacity)
        .animation(.default, value: textOpacity)
        .animation(.default, value: buttonOpacity)
    }
}

// MARK: - Previews
struct SolverView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SolverView(solveState: .waiting, buttonText: "Waiting", action: {})
            SolverView(solveState: .ready, buttonText: "Solve me", action: {})
            SolverView(solveState: .solving, buttonText: "Solving...", action: {})
            SolverView(solveState: .solved(result: "Solved!"), buttonText: "Solve me", action: {})
        }
    }
}
