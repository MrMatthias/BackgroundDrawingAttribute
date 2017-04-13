import UIKit
import CoreGraphics
import CoreText

class BackgroundAttributeView: UIView {
    
    var text:NSAttributedString = {
        
        if let font = UIFont(name:"Helvetica", size:20) {
            var att = [NSFontAttributeName:font]
            
            var text = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ullamco ", attributes:att)
            text.append(NSAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", attributes: ["kBackgroundAttribute":UIColor.cyan, NSFontAttributeName: font]))
            text.append(NSAttributedString(string: " Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", attributes:att))
            return text
        }
        return NSAttributedString()
    }()
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        let frameSetter = CTFramesetterCreateWithAttributedString(text)
        let framePath = CGMutablePath()
        
        framePath.addRect(self.bounds)
        
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, nil)
        
        _ = CTFrameGetVisibleStringRange(ctFrame)
        
        if let  ctx = UIGraphicsGetCurrentContext() {
            ctx.saveGState()
            ctx.textMatrix = CGAffineTransform.identity
            ctx.translateBy(x: 0, y: bounds.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            
            if let lines = CTFrameGetLines(ctFrame) as? [CTLine] {
                var lineOrigins:[CGPoint] = [CGPoint](repeating: CGPoint.zero, count: lines.count)
                CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &lineOrigins)
                var _:CGFloat = 0
                var lineHeight:CGFloat = 0
                
                for (lineIndex, line) in lines.enumerated() {
                    let lineOrigin = lineOrigins[lineIndex]
                    
                    let runs:NSArray = CTLineGetGlyphRuns(line)
                    for run:CTRun in runs as! [CTRun] {
                        let stringRange = CTRunGetStringRange(run)
                        var ascent:CGFloat = 0
                        var descent:CGFloat = 0
                        var leading:CGFloat = 0
                        let typographicBounds = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                        let xOffset:CGFloat = CTLineGetOffsetForStringIndex(line, stringRange.location, nil)
                        
                        ctx.textPosition = CGPoint(x: lineOrigin.x, y: lineOrigin.y + descent)
                        
                        let currentLineHeight = ascent + descent + leading
                        
                        if currentLineHeight > lineHeight {
                            lineHeight = currentLineHeight
                        }
                        let runBounds = CGRect(x: lineOrigin.x + xOffset, y: lineOrigin.y, width: CGFloat(typographicBounds), height: ascent + descent)
                        let attributes:NSDictionary = CTRunGetAttributes(run)
                        let maybeColor = attributes.value(forKey: "kBackgroundAttribute") as! UIColor?
                        if let color = maybeColor {
                            let path = UIBezierPath(roundedRect: runBounds, cornerRadius: 3)
                            color.setFill()
                            path.fill()
                        }
                        CTRunDraw(run, ctx, CFRangeMake(0, 0))
                    }
                }
                ctx.restoreGState()
            }
        }
    }
    
    override func layoutSubviews() {
        self.draw(self.bounds)
    }
}
