import UIKit
import SwiftUI
import PlaygroundSupport
import Foundation

// Mark: - Constants

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

// Mark: - Protocols and Delegates

/// A slidable object will have percentage to show how much amount of slider body is dragged.
protocol Slidable{
    var percentage: Double {get set}
    var accentColor: Colors {get set}
}

/// When percentage updated on a Slideable object value will be notified to other classes.
protocol SlidableDelegate{
    func didPercentageChange(_ newValue: Double)
}

/// A writable object with  a color value and line width as font size.
protocol Writable{
    var color: Colors {get set}
    var lineWidth: CGFloat {get set}
}

/// When color and line width changes other classes will be notified.
protocol WritableDelegate{
    func didChangeColor(_ newColor: Colors)
    func didChangeLineWidht(_ newWidth: CGFloat)
}

// Mark: - Controllers and Extensions


/// Canvas is the parent class.
class CanvasController{

    var writableDelegate: WritableDelegate?
    var slidableDelegate: SlidableDelegate?
    var sliderControllerInstance: SliderController
    
    init(){
        self.sliderControllerInstance = SliderController()
        self.sliderControllerInstance.slidableDelegate = self
    }
    
    /// Slider accent color and writeable color with delegate updated when color changes.
    /// - Parameter color: Enum color that used in project
    func changeColor(new color: Colors){
        sliderControllerInstance.accentColor = color
        writableDelegate?.didChangeColor(color)
    }
    
}

extension CanvasController: SlidableDelegate{
    /// Updated writeable objects line width.
    /// - Parameter newValue: New width amount.
    func didPercentageChange(_ newValue: Double) {
        writableDelegate?.didChangeLineWidht(newValue)
    }
}

/// Controller of the slider on UI. It contaion accent color and perentage informations.
class SliderController: Slidable, ObservableObject{
    @Published var percentage: Double = 22
    @Published var accentColor: Colors = .black
    var slidableDelegate: SlidableDelegate?
    var writableDelegate: WritableDelegate?
    
    /// When slider percented changes, value will be updated via slidable delegate.
    /// - Parameter newValue: New percentage amount.
    func changePercentage(new newValue: Double){
        self.percentage = newValue
        self.slidableDelegate?.didPercentageChange(newValue)
    }
}

extension SliderController: WritableDelegate{
    func didChangeLineWidht(_ newWidth: CGFloat) {
        return
    }
    
    func didChangeColor(_ newColor: Colors) {
        self.accentColor = newColor
    }
}

/// Controls the text editor on UI.
class TextEditorViewController: ObservableObject{
    @Published var color: Colors = .black
    @Published var lineWidht: CGFloat = 22
    private var canvasControllerInstance: CanvasController
    
    init(parent canvasController: CanvasController){
        self.canvasControllerInstance = canvasController
        self.canvasControllerInstance.writableDelegate = self
    }
    
}

extension TextEditorViewController: WritableDelegate{
    func didChangeColor(_ newColor: Colors) {
        print("Color Changed to " + newColor.name + "!")
        self.color = newColor
    }
    
    func didChangeLineWidht(_ newWidth: CGFloat) {
        self.lineWidht = newWidth
    }
}

// Mark: - Views

struct CustomSlider: View{
    
    @ObservedObject var sliderController: SliderController
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: geometry.size.width * CGFloat(self.sliderController.percentage / 100) - geometry.size.height/2)
                ZStack{
                    Circle()
                        .foregroundColor(self.sliderController.accentColor.rawValue)
                        .frame(width: geometry.size.height, height: geometry.size.height)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: geometry.size.height - 20, height: geometry.size.height - 20)
                }
                .offset(x: geometry.size.width * CGFloat(self.sliderController.percentage / 100) - geometry.size.height)
                
            }
            .cornerRadius(50)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.sliderController.changePercentage(new: Double(min(max(Float(geometry.size.height)/2, Float(value.location.x / geometry.size.width * 100)), 100)))
                }))
        }
    }
}

struct TextEditorView: View{
    @ObservedObject var textEditorViewController: TextEditorViewController
    @State var text: String = "Write here..."
    var body: some View{
        ZStack(alignment: .bottomTrailing){
        TextEditor(text: self.$text)
            .foregroundColor(textEditorViewController.color.rawValue)
            .font(.system(size: textEditorViewController.lineWidht))
        }
            
    }
    
}

struct MainCanvas: View{
    private var canvasController = CanvasController()
    var body: some View{
        VStack(spacing: 0){
            VStack{
                HStack{
                    ForEach(Colors.allCases, id: \.rawValue){ color in
                        Spacer()
                        ZStack{
                            Circle()
                                .foregroundColor(color.rawValue)
                            Circle()
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .padding()
                        }
                        
                        .onTapGesture {
                            canvasController.changeColor(new: color)
                        }
                        .frame(width: 50, height: 50, alignment: .top)
                    }
                    Spacer()
                }
                .padding()
                CustomSlider(sliderController: self.canvasController.sliderControllerInstance)
                   .accentColor(.white)
                  .frame(width: 300, height: 44)
            }
                .padding()
                .background(
                    Rectangle()
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .blur(radius: 1)
                )
            Spacer()
            TextEditorView(textEditorViewController: TextEditorViewController(parent: self.canvasController))
            Spacer()
        }
        .frame(alignment: .top)
        .background(
            Color(uiColor: .systemGray4)
        )
    }
}

PlaygroundPage.current.setLiveView(
    MainCanvas()
        .frame(width: 500, height: 800, alignment: .center)
)
