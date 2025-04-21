import SwiftUI
import MapKit

struct CrimeMapView: View {
    @StateObject private var viewModel = CrimeMapViewModel()
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.crimeNews) { news in
            MapAnnotation(coordinate: news.coordinates) {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(news.title)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 4)
            }
        }
        .onAppear {
            viewModel.fetchCrimeNews()
        }
    }
}

class CrimeMapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var crimeNews: [NewsItem] = []
    private let newsService = NewsDataService()
    
    func fetchCrimeNews() {
        newsService.fetchCrimeNews { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let news):
                    self.crimeNews = news.filter { $0.coordinates != nil }
                    
                    // If we have news items, center the map on the first one
                    if let firstNews = self.crimeNews.first {
                        self.region.center = firstNews.coordinates
                    }
                    
                case .failure(let error):
                    print("Error fetching crime news: \(error.localizedDescription)")
                }
            }
        }
    }
} 