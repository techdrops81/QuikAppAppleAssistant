# QuikApp Support Assistant

A comprehensive Flutter application for managing Apple Developer Portal certificates, identifiers, and provisioning profiles. This assistant provides a user-friendly interface for iOS developers to streamline their certificate and profile management workflow.

## Features

### 🏢 App Management

- Create and manage app identifiers
- Store bundle IDs and team information
- Track app descriptions and metadata

### 🔐 Certificate Management

- Generate Certificate Signing Requests (CSR) using Python scripts
- Create development, distribution, and push certificates
- Export certificates in various formats (PEM, P12)
- Parse and display certificate information
- Track certificate expiry dates

### 📋 Provisioning Profile Management

- Create different types of provisioning profiles:
  - Development
  - Ad Hoc
  - App Store
  - Enterprise
- Associate profiles with apps and certificates
- Download and manage profile files

### 🌐 Apple Developer Portal Integration

- Authenticate with Apple ID and App Specific Password
- Sync data with Apple Developer Portal
- Create certificates and profiles directly from the portal
- Download existing certificates and profiles

### 💾 Local Database

- SQLite database for local storage
- No intermediate storage - all files downloaded directly
- Secure storage of sensitive information

### 📱 Responsive Design

- Cross-platform support (iOS, Android, macOS, Windows, Linux)
- Adaptive UI for mobile, tablet, and desktop
- Modern Material Design 3 interface

## Prerequisites

### Flutter Setup

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code with Flutter extensions

### Python Dependencies

- Python 3.7 or higher
- PyOpenSSL library

### Apple Developer Account

- Active Apple Developer Program membership
- Apple ID with App Specific Password
- Team ID for your development team

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd quikappappleassistant
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Install Python Dependencies

```bash
pip install pyopenssl
```

### 4. Make Python Script Executable

```bash
chmod +x scripts/certificate_generator.py
```

### 5. Run the Application

```bash
flutter run
```

## Configuration

### Apple Developer Portal Setup

1. **Generate App Specific Password**

   - Go to [Apple ID](https://appleid.apple.com)
   - Sign in with your Apple ID
   - Navigate to Security > App-Specific Passwords
   - Generate a new password for QuikApp Assistant

2. **Get Your Team ID**

   - Log in to [Apple Developer Portal](https://developer.apple.com)
   - Go to Membership Details
   - Note your Team ID (10-character string)

3. **Configure App Settings**
   - Open the app and go to Settings
   - Enter your Apple ID
   - Enter your App Specific Password
   - Enter your Team ID
   - Test the connection

## Usage

### Creating a Certificate

1. **Navigate to Certificates Screen**

   - Tap the "Certificates" tab
   - Click the "+" button to create a new certificate

2. **Fill Certificate Details**

   - Enter certificate name
   - Select certificate type (Development/Distribution/Push)
   - Provide organization details for CSR generation

3. **Generate CSR**

   - The app will automatically generate a CSR using Python scripts
   - Private key and CSR files are created locally

4. **Upload to Apple Developer Portal**

   - The CSR is uploaded to Apple Developer Portal
   - Certificate is created and downloaded automatically

5. **Export Options**
   - Download certificate in PEM format
   - Create P12 file with optional password protection

### Creating a Provisioning Profile

1. **Navigate to Profiles Screen**

   - Tap the "Profiles" tab
   - Click the "+" button to create a new profile

2. **Select Profile Type**

   - Choose from Development, Ad Hoc, App Store, or Enterprise
   - Select the associated app identifier
   - Choose certificates to include

3. **Configure Devices (if applicable)**

   - For Development and Ad Hoc profiles, select devices
   - For App Store profiles, no device selection needed

4. **Create and Download**
   - Profile is created in Apple Developer Portal
   - Automatically downloaded and stored locally

### Managing Apps

1. **Add App Information**

   - Navigate to Apps screen
   - Click "+" to add a new app
   - Enter app name, bundle ID, and team ID
   - Add optional description

2. **View App Details**
   - See all associated certificates and profiles
   - Track app status and metadata

## File Structure

```
quikappappleassistant/
├── lib/
│   ├── models/           # Data models
│   ├── services/         # Business logic and API services
│   ├── screens/          # UI screens
│   ├── widgets/          # Reusable UI components
│   ├── database/         # SQLite database helper
│   └── utils/            # Utility functions
├── scripts/
│   └── certificate_generator.py  # Python certificate scripts
├── assets/
│   ├── images/           # App images
│   ├── icons/            # App icons
│   └── fonts/            # Custom fonts
└── test/                 # Unit and widget tests
```

## Database Schema

### Apps Table

- `id` (PRIMARY KEY)
- `name` (TEXT)
- `bundleId` (TEXT, UNIQUE)
- `teamId` (TEXT)
- `description` (TEXT)
- `createdAt` (TEXT)
- `updatedAt` (TEXT)

### Certificates Table

- `id` (PRIMARY KEY)
- `name` (TEXT)
- `type` (TEXT)
- `csrPath` (TEXT)
- `keyPath` (TEXT)
- `certificatePath` (TEXT)
- `p12Path` (TEXT)
- `p12Password` (TEXT)
- `serialNumber` (TEXT)
- `expiryDate` (TEXT)
- `isActive` (INTEGER)
- `createdAt` (TEXT)
- `updatedAt` (TEXT)

### Profiles Table

- `id` (PRIMARY KEY)
- `name` (TEXT)
- `type` (TEXT)
- `appId` (TEXT)
- `certificateId` (TEXT)
- `deviceIds` (TEXT)
- `profilePath` (TEXT)
- `uuid` (TEXT)
- `expiryDate` (TEXT)
- `isActive` (INTEGER)
- `createdAt` (TEXT)
- `updatedAt` (TEXT)

## Security Considerations

- **App Specific Passwords**: Always use App Specific Passwords instead of your main Apple ID password
- **Local Storage**: Sensitive data is stored locally in SQLite database
- **File Permissions**: Certificate files are stored with appropriate permissions
- **No Cloud Storage**: All data remains on your device for security

## Troubleshooting

### Common Issues

1. **Python Script Not Found**

   - Ensure Python 3.7+ is installed
   - Install PyOpenSSL: `pip install pyopenssl`
   - Make script executable: `chmod +x scripts/certificate_generator.py`

2. **Authentication Failed**

   - Verify Apple ID and App Specific Password
   - Check Team ID is correct
   - Ensure Apple Developer Program membership is active

3. **Certificate Generation Failed**

   - Check Python script permissions
   - Verify OpenSSL installation
   - Review error logs in app

4. **Database Errors**
   - Clear app data and restart
   - Check device storage space
   - Verify SQLite permissions

### Error Logs

Check the app's error logs for detailed information about failures. Common error locations:

- Certificate generation: Python script output
- API calls: Network request logs
- Database: SQLite error messages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue on GitHub
- Check the troubleshooting section
- Review Apple Developer documentation

## Roadmap

- [ ] Push notification certificate management
- [ ] Automatic certificate renewal
- [ ] Bulk operations for multiple certificates
- [ ] Integration with Xcode
- [ ] Cloud backup and sync
- [ ] Advanced certificate analytics
- [ ] Team collaboration features

---

**Note**: This application is designed to work with Apple Developer Portal APIs. Ensure compliance with Apple's terms of service and API usage guidelines.
