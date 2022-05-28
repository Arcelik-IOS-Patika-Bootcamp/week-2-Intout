import UIKit
import SwiftUI
import PlaygroundSupport

enum Colors: CaseIterable{
    
    case red, blue, yellow, black, purple, pink
    
    var rawValue: Color{
        switch self{
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        case .black: return .black
        case .purple: return .purple
        case .pink: return .pink
        }
    }
    
    var name: String{
        switch self{
        case .red: return "Red"
        case .blue: return "Blue"
        case .yellow: return "Yellow"
        case .black: return "Black"
        case .purple: return "Purple"
        case .pink: return "Pink"
        }
    }
}

protocol Drawer{
    var color: Colors {get set}
    var lineWidth: CGFloat {get set}
}

protocol DrawerDelegate{
    func didChangeColor(_ newColor: Colors)
    func didChangeLineWidht(_ newWidth: CGFloat)
}



class CanvasController: Drawer{
    var color: Colors = .black
    var lineWidth: CGFloat = 1.0
    var pencilDelegate: DrawerDelegate?
    
    func changeColor(new color: Colors){
        self.color  = color
        print(self.color.name)
        pencilDelegate?.didChangeColor(color)
    }
}

class DrawingCanvasController{
    var color: Colors
    var lineWidht: CGFloat
    private var canvasControllerInstance: CanvasController
    
    init(parent canvasController: CanvasController){
        self.canvasControllerInstance = canvasController
        self.color = canvasController.color
        self.lineWidht = canvasController.lineWidth
        self.canvasControllerInstance.pencilDelegate = self
    }
    
}

extension DrawingCanvasController: DrawerDelegate{
    func didChangeColor(_ newColor: Colors) {
        print("Color Changed to " + newColor.name + "!")
        self.color = newColor
    }
    
    func didChangeLineWidht(_ newWidth: CGFloat) {
        print("Line width changed to \(newWidth)!")
        self.lineWidht = newWidth
    }
}

struct DrawingCanvas: View{
    var drawingCanvasController: DrawingCanvasController
    var body: some View{
        Button(action: {
            print(self.drawingCanvasController.color.name)
        }){
            Text("Print Color Name")
        }
    }
}

struct CustomSlider: View{
    @Binding var percentage: Float
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100) - geometry.size.height/2)
                ZStack{
                    Circle()
                        .frame(width: geometry.size.height, height: geometry.size.height)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: geometry.size.height - 20, height: geometry.size.height - 20)
                }
                .offset(x: geometry.size.width * CGFloat(self.percentage / 100) - geometry.size.height)
                
            }
            .onAppear{
                self.percentage = Float(geometry.size.height)/2
                print("Percentage: \(percentage)")
            }
            .cornerRadius(50)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.percentage = min(max(Float(geometry.size.height)/2, Float(value.location.x / geometry.size.width * 100)), 100)
                        print("Percentage: \(percentage)")
                }))
        }
    }
}

struct MainCanvas: View{
    @State private var currentDrawing: [CGPoint] = []
    @State private var drawing: [[CGPoint]] = []
    @State private var sliderPercentage: Float = 1
    private var pencilController = CanvasController()
    var body: some View{
        VStack(spacing: 0){
            HStack{
                ForEach(Colors.allCases, id: \.rawValue){ color in
                    ZStack{
                        Circle()
                            .foregroundColor(color.rawValue)
                        Circle()
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding()
                    }
                    .onTapGesture {
                        pencilController.changeColor(new: color)
                    }
                }
            }
            .padding()
            CustomSlider(percentage: self.$sliderPercentage)
                .accentColor(.white)
                .frame(width: 500, height: 44)
            DrawingCanvas(drawingCanvasController: DrawingCanvasController(parent: self.pencilController))
        }
    }
    
}

PlaygroundPage.current.setLiveView(
    MainCanvas()
        .frame(width: 500, height: 400, alignment: .center)
)
