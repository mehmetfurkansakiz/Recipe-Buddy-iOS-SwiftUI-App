import Foundation
import SwiftUI
import AWSS3
import Smithy
import AWSSDKIdentity

@MainActor
class ImageUploaderService {
    static let shared = ImageUploaderService()
    
    private let s3Client: S3Client
    private let bucketName = Secrets.s3BucketName
    private let cloudFrontURL = Secrets.cloudfrontDomain
    
    private init() {
        do {
            let credentials = AWSCredentialIdentity(
                accessKey: Secrets.awsAccessKeyID,
                secret: Secrets.awsSecretAccessKey
            )
            
            let identityResolver = StaticAWSCredentialIdentityResolver(credentials)
            
            let config = try S3Client.S3ClientConfiguration(
                awsCredentialIdentityResolver: identityResolver,
                region: Secrets.s3Region
            )
            
            self.s3Client = S3Client(config: config)
        } catch {
            fatalError("❌ AWS S3 configuration failed: \(error)")
        }
    }
    
    // MARK: - Upload
    /// Uploads image data to the S3 bucket and returns the unique key (path).
    func uploadImage(imageData: Data, maxLength: CGFloat = 1920) async throws -> String {
        guard let image = UIImage(data: imageData) else {
            throw NSError(domain: "ImageUploader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image decoding failed"])
        }
        
        let resized = resizeImageMaintainingAspect(image: image, maxLength: maxLength)
                
        guard let finalData = resized.compressedData(maxSizeInMB: 0.5) else {
            throw NSError(domain: "ImageUploader", code: -2, userInfo: [NSLocalizedDescriptionKey: "JPEG compression failed"])
        }
        
        // Create a unique name for the image file
        let key = "public/\(UUID().uuidString).jpg"
        let body = ByteStream.data(finalData)
        
        let input = PutObjectInput(
            body: body,
            bucket: bucketName,
            contentType: "image/jpeg",
            key: key
        )
        
        _ = try await s3Client.putObject(input: input)
        print("✅ Successfully uploaded image to S3 with key: \(key)")
        return key
    }
    
    private func resizeImageMaintainingAspect(image: UIImage, maxLength: CGFloat) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        
        let scale = (width > height) ? maxLength / width : maxLength / height
        if scale >= 1 { return image } // zaten küçükse bırak
        
        let newSize = CGSize(width: width * scale, height: height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // MARK: - Fetch
    func fetchImageURL(for key: String) -> URL? {
        return URL(string: "\(cloudFrontURL)/\(key)")
    }
    
    // MARK: - Delete
    func deleteImage(for key: String) async throws {
        let input = DeleteObjectInput(
            bucket: bucketName,
            key: key
        )
        _ = try await s3Client.deleteObject(input: input)
        print("🗑️ Deleted image with key: \(key)")
    }
}
