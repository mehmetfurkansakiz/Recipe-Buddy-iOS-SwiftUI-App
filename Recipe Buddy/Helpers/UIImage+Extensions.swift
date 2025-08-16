import PhotosUI

extension UIImage {
    func jpegData(maxWidth: CGFloat, compressionQuality: CGFloat) -> Data? {
        let newSize = self.size.width > maxWidth ?
            CGSize(width: maxWidth, height: self.size.height * (maxWidth / self.size.width)) : self.size
            
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let data = renderer.jpegData(withCompressionQuality: compressionQuality) { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return data
    }
}
