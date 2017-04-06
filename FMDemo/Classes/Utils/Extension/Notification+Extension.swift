import UIKit

extension Notification.Name {
    
    /// 生命周期
    public struct LifeCycle {
        public static let WillResignActive = Notification.Name("appWillResignActive")
    }
    

    public static let shouldReLoadMainData = Notification.Name("shouldReLoadMainData")
}
