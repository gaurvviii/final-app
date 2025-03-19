# Nyx - Women's Safety App

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

### Crime Data Analysis
The app incorporates crime data analysis to identify:

1. **High-risk Areas**: Areas with historically higher incidents of crimes against women.
2. **Time-based Risk Assessment**: Certain areas may be safer during the day but risky at night.
3. **Safety Recommendations**: Customized safety tips based on location and time.

The crime data helps in:
- Generating heat maps of unsafe areas
- Providing safety scores for different neighborhoods
- Alerting users when they enter high-risk zones

## Technical Implementation

- **Location Services**: Real-time location tracking with background updates
- **SwiftUI Interface**: Modern, intuitive user interface with dark mode support
- **Data Visualization**: Map overlays showing safety zones and risk areas
- **Local Notifications**: Alerts when entering high-risk areas

## Privacy and Security

The app prioritizes user privacy while providing safety features:
- Location data is only shared with explicit user permission
- Emergency contacts are stored locally on the device
- No unnecessary data collection or tracking

## Future Enhancements

- **Community Reporting**: Allow users to report unsafe incidents to build a more accurate safety map
- **Safety Routes**: Generate walking/transportation routes that prioritize well-lit, populated areas
- **Audio/Video Recording**: Quick access to record evidence in threatening situations
- **Integration with Official Crime Data APIs**: Regular updates from police databases
- **AI-Powered Risk Prediction**: Use machine learning to predict and prevent potential risks

## Credits

Police and crime data sourced from government records and analyzed to provide meaningful safety intelligence. 