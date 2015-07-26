import UIKit
import CoreGraphics
import CoreText

class BackgroundAttributeView: UIView {
    
    var text:NSAttributedString = {
        var att = [NSFontAttributeName:UIFont(name:"Helvetica", size:20)!]

        var text = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis ullamco", attributes:att)
        text.appendAttributedString(NSAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed  in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum", attributes: ["kBackgroundAttribute":UIColor.cyanColor()]))
        text.appendAttributedString(NSAttributedString(string: " Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", attributes:att))
        return text
    }()
    
    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)
        var frameSetter = CTFramesetterCreateWithAttributedString(text)
        var framePath = CGPathCreateMutable()
        CGPathAddRect(framePath, nil, self.bounds)
        var ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, nil)
        var frameRange = CTFrameGetVisibleStringRange(ctFrame)
        var ctx = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)
        
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity)
        CGContextTranslateCTM(ctx, 0, bounds.height)
        CGContextScaleCTM(ctx, 1.0, -1.0)
    
        
        var lines:NSArray = CTFrameGetLines(ctFrame)
        var lineOrigins:[CGPoint] = [CGPoint](count:lines.count, repeatedValue:CGPointZero)
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &lineOrigins)
        var currentLineHeight:CGFloat = 0
        var lineHeight:CGFloat = 0
        for (lineIndex, line) in enumerate(lines) {
            let lineOrigin = lineOrigins[lineIndex]
            
            var runs:NSArray = CTLineGetGlyphRuns(line as! CTLine)
            for run:CTRunRef in runs as! [CTRunRef] {
                let stringRange = CTRunGetStringRange(run)
                var ascent:CGFloat = 0
                var descent:CGFloat = 0
                var leading:CGFloat = 0
                let typographicBounds = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                var xOffset:CGFloat = CTLineGetOffsetForStringIndex(line as! CTLine, stringRange.location, nil)
                CGContextSetTextPosition(ctx, lineOrigin.x ,lineOrigin.y + descent )
                var currentLineHeight = ascent + descent + leading
                if currentLineHeight > lineHeight {
                    lineHeight = currentLineHeight
                }
                var runBounds = CGRectMake(lineOrigin.x + xOffset, lineOrigin.y, CGFloat(typographicBounds), ascent + descent)
                var attributes:NSDictionary = CTRunGetAttributes(run)
                var maybeColor = attributes.valueForKey("kBackgroundAttribute") as! UIColor?
                if let color = maybeColor {
                    let path = UIBezierPath(roundedRect: runBounds, cornerRadius: 3)
                    color.setFill()
                    path.fill()
                }
                CTRunDraw(run, ctx, CFRangeMake(0, 0))
            }
        }
        CGContextRestoreGState(ctx)
    }
}
