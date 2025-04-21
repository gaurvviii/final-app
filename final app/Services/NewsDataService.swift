import Foundation
import CoreLocation
import MapKit

class NewsDataService: ObservableObject {
    @Published var crimeNews: [NewsItem] = []
    private let apiKey = "5cde20636ba24dafa9325ae5383f3e9c"
    private let keywords = ["rape", "assault", "women", "girl"]
    
    func fetchCrimeNews(completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        let baseUrl = "https://newsapi.org/v2/everything"
        let query = keywords.joined(separator: " OR ")
        let urlString = "\(baseUrl)?q=\(query)&apiKey=\(apiKey)&language=en&sortBy=publishedAt"
        
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("❌ Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let newsResponse = try decoder.decode(NewsAPIResponse.self, from: data)
                
                let newsItems = newsResponse.articles.compactMap { article -> NewsItem? in
                    guard let coordinates = self?.extractLocationCoordinates(from: article.description ?? "") else {
                        return nil
                    }
                    
                    return NewsItem(
                        id: UUID(),
                        title: article.title,
                        description: article.description ?? "",
                        url: article.url,
                        coordinates: coordinates,
                        publishedAt: article.publishedAt
                    )
                }
                
                DispatchQueue.main.async {
                    self?.crimeNews = newsItems
                    completion(.success(newsItems))
                }
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func extractLocationCoordinates(from text: String) -> CLLocationCoordinate2D? {
        // List of Bangalore area keywords and their approximate coordinates
        let locationKeywords: [(keyword: String, coordinate: CLLocationCoordinate2D)] = [
            ("Koramangala", CLLocationCoordinate2D(latitude: 12.9279, longitude: 77.6271)),
            ("Indiranagar", CLLocationCoordinate2D(latitude: 12.9784, longitude: 77.6408)),
            ("MG Road", CLLocationCoordinate2D(latitude: 12.9759, longitude: 77.6074)),
            ("Whitefield", CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7500)),
            ("Electronic City", CLLocationCoordinate2D(latitude: 12.8399, longitude: 77.6770)),
            ("HSR Layout", CLLocationCoordinate2D(latitude: 12.9116, longitude: 77.6474)),
            ("BTM Layout", CLLocationCoordinate2D(latitude: 12.9166, longitude: 77.6101)),
            ("Jayanagar", CLLocationCoordinate2D(latitude: 12.9250, longitude: 77.5938)),
            ("JP Nagar", CLLocationCoordinate2D(latitude: 12.9077, longitude: 77.5851)),
            ("Malleswaram", CLLocationCoordinate2D(latitude: 13.0035, longitude: 77.5647))
        ]
        
        for (keyword, coordinate) in locationKeywords {
            if text.lowercased().contains(keyword.lowercased()) {
                return coordinate
            }
        }
        
        // If no specific location is found, return nil
        return nil
    }
}

// Models for NewsAPI.org response
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let url: String
    let publishedAt: String
}

struct NewsItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let url: String
    let coordinates: CLLocationCoordinate2D
    let publishedAt: String
} 