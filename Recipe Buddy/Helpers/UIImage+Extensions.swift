import PhotosUI

extension UIImage {
    /// Resizes and compresses an image to be below a certain file size in megabytes.
    func compressedData(maxSizeInMB: Double) -> Data? {
        let maxSizeBytes = Int(maxSizeInMB * 1024 * 1024)
        var compressionQuality: CGFloat = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: self.size)
        
        var imageData = renderer.jpegData(withCompressionQuality: compressionQuality, actions: { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        })

        // This loop continues as long as the data is too large AND we haven't hit the quality limit.
        while imageData.count > maxSizeBytes && compressionQuality > 0.1 {
            // Reduce the quality by 10%
            compressionQuality -= 0.1
            
            // Re-render the image with the new, lower quality.
            imageData = renderer.jpegData(withCompressionQuality: compressionQuality, actions: { _ in
                self.draw(in: CGRect(origin: .zero, size: self.size))
            })
        }
        return imageData
    }
}
