import UIKit

//由于swift函数问题，所以添加次方法实现storyboard中，边框颜色设置生效
extension CALayer {
    var borderColorFromUIColor: UIColor {
        get {
            return UIColor(cgColor: self.borderColor!)
        } set {
            self.borderColor = newValue.cgColor
        }
    }
}
