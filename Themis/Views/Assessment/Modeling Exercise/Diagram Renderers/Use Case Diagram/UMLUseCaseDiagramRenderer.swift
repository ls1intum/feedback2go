//
//  UMLUseCaseDiagramRenderer.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 02.08.23.
//

import SwiftUI

struct UMLUseCaseDiagramRenderer: UMLDiagramRenderer {
    var context: UMLGraphicsContext
    let canvasBounds: CGRect
    var fontSize: CGFloat
    
    init(context: GraphicsContext, canvasBounds: CGRect, fontSize: CGFloat = 14) {
        self.context = UMLGraphicsContext(context)
        self.canvasBounds = canvasBounds
        self.fontSize = fontSize
    }
    
    func render(umlModel: UMLModel) {
        let elementRenderer = UMLUseCaseDiagramElementRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        let relationshipRenderer = UMLUseCaseDiagramRelationshipRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        
        elementRenderer.render(umlModel: umlModel)
        relationshipRenderer.render(umlModel: umlModel)
    }
}