import UIKit
import Lottie

class NewButton: UIButton {
    
    let starAnimationView = LottieAnimationView(name: "food_01")
    
    private let defaultShadowOpacity: Float = 0.5
    private let defaultShadowOffset = CGSize(width: 0, height: 5)
    private let defaultShadowRadius: CGFloat = 5
    
    override var isHighlighted: Bool {
        didSet {
            animateShadow(isHighlighted: isHighlighted)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        // 添加图片视图作为子视图
//        starAnimationView.translatesAutoresizingMaskIntoConstraints = false
//        starAnimationView.frame.size.height = self.frame.size.height - (self.titleLabel?.frame.size.height ?? 30)
//        addSubview(starAnimationView)
//        
//        // 设置图片视图的约束
//        NSLayoutConstraint.activate([
//            starAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            starAnimationView.bottomAnchor.constraint(equalTo: self.titleLabel!.topAnchor, constant: -5),
//            starAnimationView.widthAnchor.constraint(equalToConstant: 40),
//            starAnimationView.heightAnchor.constraint(equalToConstant: 40)
//        ])
        
        // 调整按钮标题的边距
//        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        // 设置阴影属性
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = defaultShadowOffset
        layer.shadowRadius = defaultShadowRadius
        layer.shadowOpacity = defaultShadowOpacity
    }
    
    private func animateShadow(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.1) {
            if isHighlighted {
                // 当按钮被按下时，移除阴影
                self.layer.shadowOpacity = 0.1
            } else {
                // 当按钮被释放时，恢复阴影
                self.layer.shadowOpacity = self.defaultShadowOpacity
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
