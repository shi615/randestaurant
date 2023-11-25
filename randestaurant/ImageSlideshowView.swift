import UIKit

class ImageSlideshowView: UIView, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var images: [UIImage] = []

    init(frame: CGRect, images: [UIImage]) {
        super.init(frame: frame)
        self.images = images
        setupScrollView()
        setupPageControl()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }

    private func setupPageControl() {
        pageControl = UIPageControl()
        addSubview(pageControl)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: bounds.height - 40, width: bounds.width, height: 40)

        scrollView.subviews.forEach { $0.removeFromSuperview() } // 清除旧的子视图

        for (index, image) in images.enumerated() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: bounds.width * CGFloat(index), y: 0, width: bounds.width, height: bounds.height)

            imageView.layer.cornerRadius = 20
            imageView.clipsToBounds = true

            scrollView.addSubview(imageView)
        }

        scrollView.contentSize = CGSize(width: bounds.width * CGFloat(images.count), height: bounds.height)
        pageControl.numberOfPages = images.count
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / bounds.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
