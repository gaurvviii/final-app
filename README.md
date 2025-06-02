# Nyx - Women's Safety App

## App Screenshots

<p align="center">
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.05.13.png" alt="Screenshot 1" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.05.19.png" alt="Screenshot 2" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.05.31.png" alt="Screenshot 3" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.05.39.png" alt="Screenshot 4" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.05.43.png" alt="Screenshot 5" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.02.44.png" alt="Screenshot 6" width="180"/>
  <img src="public/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-06-03%20at%2000.02.55.png" alt="Screenshot 7" width="180"/>
</p>

A comprehensive women's safety application built with SwiftUI that focuses on real-time location tracking, safety features, and emergency assistance.

## Key Features

- **Real-time Safety Map**: Shows unsafe areas and police stations based on crime data analysis.
- **Safety Intelligence**: Provides safety tips and crime statistics derived from real crime data.
- **Emergency Resources**: Quick access to emergency contacts, women's helplines, and police stations.
- **SOS Button**: One-tap emergency alert with location sharing to trusted contacts.
- **Live Location Sharing**: Share your real-time location with trusted contacts.

## Data Integration

### Police Station Data
The app integrates police station data from Bangalore to provide users with information about nearby police stations, especially those with women's help desks. The data includes:

- Station names and codes
- Complete addresses
- Contact numbers
- Geographic coordinates

When a user is in an unsafe area, the app can navigate them to the nearest police station or provide contact details for immediate assistance.

### Crime Data API Integration
The app connects to a real-time crime data API to fetch information about crimes against women in major metropolitan cities. The integration:

1. **Uses API Key Authentication**: Securely connects to the crime data service.
2. **Fetches Live Data**: Retrieves the latest crime statistics from the official government database.
3. **Covers Multiple Cities**: Includes data for Bangalore, Delhi, Mumbai, Chennai, and Kolkata.
4. **Provides Detailed Records**: Each crime record includes location, type, time pattern, and severity.

If the API is unavailable, the app falls back to locally stored crime data to ensure functionality is maintained.

### Crime Data Analysis
The app incorporates crime data analysis to identify:

1. **High-risk Areas**: Areas with historically higher incidents of crimes against women.
2. **Time-based Risk Assessment**: Certain areas may be safer during the day but risky at night.
3. **Safety Recommendations**: Customized safety tips based on location and time.

The crime data helps in:
- Generating heat maps of unsafe areas
- Providing safety scores for different neighborhoods
- Alerting users when they enter high-risk zones
- Creating data-driven safety recommendations specific to each area

## Technical Implementation

- **Location Services**: Real-time location tracking with background updates
- **SwiftUI Interface**: Modern, intuitive user interface with dark mode support
- **Data Visualization**: Map overlays showing safety zones and risk areas
- **Local Notifications**: Alerts when entering high-risk areas
- **CrimeDataService**: A dedicated service that manages fetching, processing, and analyzing crime data
- **Dynamic Filtering**: Users can filter crime data by city and time of day for personalized safety information

## Privacy and Security

The app prioritizes user privacy while providing safety features:
- Location data is only shared with explicit user permission
- Emergency contacts are stored locally on the device
- No unnecessary data collection or tracking
- API communications are secured and encrypted

## Future Enhancements

- **Community Reporting**: Allow users to report unsafe incidents to build a more accurate safety map
- **Safety Routes**: Generate walking/transportation routes that prioritize well-lit, populated areas
- **Audio/Video Recording**: Quick access to record evidence in threatening situations
- **Integration with Official Crime Data APIs**: Regular updates from police databases
- **AI-Powered Risk Prediction**: Use machine learning to predict and prevent potential risks
- **Expanded City Coverage**: Add more cities to the crime data coverage

## Credits

Police and crime data sourced from government records and analyzed to provide meaningful safety intelligence. 
Crime data API provided by [data.gov.in](https://data.gov.in). 