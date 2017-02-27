import UIKit

//由于swift函数问题，所以添加次方法实现storyboard中，边框颜色设置生效
extension TimeInterval {
    
    
    /// 格式化为00 ：00
    ///
    /// - Parameter isSpace: 是否有空格，默认true（如false，00:00)
    /// - Returns: 字符串
    func getFormatTime(isSpace: Bool? = true) -> String {
        if isSpace! {
            if self.isNaN {
                return "00 : 00"
            }
            let min = Int(self) / 60
            let sec = Int(self) % 60
            return String(format: "%02d : %02d", min, sec)
        } else {
            if self.isNaN {
                return "00:00"
            }
            let min = Int(self) / 60
            let sec = Int(self) % 60
            return String(format: "%02d:%02d", min, sec)
        }        
    }
}
