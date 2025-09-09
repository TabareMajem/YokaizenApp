class AudioApiConfig {
  // API keys for various services
  // Replace these with your actual API keys
  static const String freesoundApiKey = 'YOUR_FREESOUND_API_KEY';
  static const String musopenApiKey = 'YOUR_MUSOPEN_API_KEY';
  static const String freeMusicArchiveApiKey = 'YOUR_FMA_API_KEY';
  
  // Base URLs for audio service APIs
  static const String freesoundBaseUrl = 'https://freesound.org/apiv2';
  static const String musopenBaseUrl = 'https://musopen.org/api';
  static const String ccMixterBaseUrl = 'http://ccmixter.org/api';
  static const String fmaBaseUrl = 'https://freemusicarchive.org/api';
  
  // Your backend endpoint for storing and retrieving audio
  static const String backendAudioEndpoint = 'https://your-api.example.com/audio';
  
  // Rate limiting and request constraints
  static const int maxResultsPerPage = 20;
  static const int requestTimeoutMilliseconds = 5000;
  
  // Settings for uploaded audio assets
  static const int maxUploadSizeMB = 10; // 10 MB max file size
  static const List<String> supportedAudioFormats = [
    'mp3', 'wav', 'ogg', 'm4a'
  ];
  
  // Initial page load counts
  static const int initialAssetLoadCount = 30;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Function to validate audio file extension
  static bool isValidAudioFormat(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) return false;
    
    final extension = parts.last.toLowerCase();
    return supportedAudioFormats.contains(extension);
  }
}
