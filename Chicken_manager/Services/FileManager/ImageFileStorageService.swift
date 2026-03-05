import UIKit

final class ImageFileStorageService {
    
    static let shared = ImageFileStorageService()
    
    private let fileManager: FileManager
    private let directoryURL: URL
    
    enum ImageFormat {
        case png
        case jpeg(compressionQuality: CGFloat)
        
        var fileExtension: String {
            switch self {
            case .png: return "png"
            case .jpeg: return "jpg"
            }
        }
    }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentsURL = urls.first else {
            fatalError("Unable to access documents directory")
        }
        
        self.directoryURL = documentsURL
    }

    func save(image: UIImage, uuid: UUID, format: ImageFormat = .png) throws {
        let fileURL = makeFileURL(for: uuid, format: format)
        
        let data: Data
        
        switch format {
        case .png:
            guard let pngData = image.pngData() else {
                throw StorageError.encodingFailed
            }
            data = pngData
            
        case .jpeg(let quality):
            guard let jpegData = image.jpegData(compressionQuality: quality) else {
                throw StorageError.encodingFailed
            }
            data = jpegData
        }
        
        try data.write(to: fileURL, options: .atomic)
    }
    
    func load(uuid: UUID) -> UIImage? {
        guard let fileURL = findFileURL(for: uuid) else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    func remove(uuid: UUID) throws {
        guard let fileURL = findFileURL(for: uuid) else { return }
        try fileManager.removeItem(at: fileURL)
    }
    
    func exists(uuid: UUID) -> Bool {
        return findFileURL(for: uuid) != nil
    }
    
    private func makeFileURL(for uuid: UUID, format: ImageFormat) -> URL {
        let fileName = uuid.uuidString + "." + format.fileExtension
        return directoryURL.appendingPathComponent(fileName)
    }
    
    private func findFileURL(for uuid: UUID) -> URL? {
        let pngURL = directoryURL.appendingPathComponent(uuid.uuidString + ".png")
        let jpgURL = directoryURL.appendingPathComponent(uuid.uuidString + ".jpg")
        
        if fileManager.fileExists(atPath: pngURL.path) {
            return pngURL
        }
        
        if fileManager.fileExists(atPath: jpgURL.path) {
            return jpgURL
        }
        
        return nil
    }
}
