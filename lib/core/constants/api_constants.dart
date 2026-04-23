class ApiConstants {
  // Use the production base URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.koushiksoftwaresolutions.online/api',
  );

  // Auth
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String getMe = '/auth/me';

  // Hostels
  static const String hostels = '/hostels';
  static const String hostelsHome = '/hostels/home';
  // GET /hostels/public/{id} - use: '$hostels/public/$id'
  // GET /hostels/{id} - use: '$hostels/$id'

  // Bookings
  static const String bookings = '/bookings';
  static const String ownerBookings = '/bookings/owner-bookings';
  static const String myBookings = '/bookings/my-bookings';
  static const String manualCheckin = '/bookings/manual-checkin';
  static const String scanBooking = '/bookings/scan';
  static const String assignRoom = '/bookings/checkin'; // Aliased to checkin for room assignment
  static const String checkoutBooking = '/bookings/checkout'; // + /{id}
  static const String cancelBooking = '/bookings/cancel';
  static const String confirmBooking = '/bookings/confirm'; // + /{id}
  static const String pendingBookings = '/bookings/owner-bookings';

  // Rooms
  static const String rooms = '/rooms';
  static const String roomsOccupancy = '/rooms/occupancy';
  static const String roomsFloors = '/rooms/floors';
  static const String roomsByFloor = '/rooms/by-floor';
  static const String roomBeds = '/rooms'; // + /{roomId}/beds
  static const String roomBedDetail = '/rooms/bed'; // + /{roomId}/{bedNumber}
  static const String roomBedHistory = '/rooms/bed-history'; // + /{roomId}/{bedNumber}
  static const String roomsPublic = '/rooms/public/hostel'; // + /{hostelId}

  // Dashboard
  static const String dashboardDailyOps = '/dashboard/daily-operations'; // + /{hostelId}
  static const String dashboardOccupancy = '/dashboard/occupancy';

  // Food Menu
  static const String foodMenu = '/food-menu'; // POST: save, GET: /{hostelId}/{day}, DELETE: /{hostelId}/{day}
  static const String foodMenuWeekly = '/food-menu/weekly'; // DELETE: /{hostelId}
  static const String foodMenuPublic = '/food-menu/public'; // GET: /{hostelId}

  // Settings
  static const String settings = '/settings'; // GET /{hostelId}
  // PATCH /{hostelId}/profile, /amenities, /house-rules, /room-configuration, /notifications

  // Tenants
  static const String tenants = '/tenants';
  static const String tenantDetail = '/tenants'; // GET /:id?hostelId=

  // Community
  static const String community = '/community'; // GET /{hostelId}/messages, POST /message, GET /{hostelId}

  // Owner Community
  static const String ownerCommunity = '/owner-community'; // GET ?hostelId=, POST, GET /{id}, POST /{id}/replies

  // Announcements
  static const String announcements = '/announcements';

  // Tickets (replaces /complaints and /maintenance — use type=COMPLAINT or type=MAINTENANCE)
  static const String tickets = '/tickets'; // POST, GET, GET /{id}, PATCH /{id}, DELETE /{id}

  // Notices
  static const String notices = '/notices'; // POST, GET, GET /{id}, PATCH /{id}

  // Payments
  static const String payments = '/payments'; // POST, GET
  static const String paymentPay = '/payments'; // PATCH /{id}/pay
  static const String paymentRemind = '/payments'; // POST /{id}/remind
  static const String paymentRemindBulk = '/payments/remind-bulk';
  static const String paymentReminders = '/payments/reminders';
  static const String bills = '/bills'; // GET /{tenantId}?hostelId=

  // Transactions
  static const String transactions = '/transactions'; // POST

  // Bookings (additional)
  static const String bookingsCheckin = '/bookings/checkin'; // POST
  static const String bookingsCheckinData = '/bookings/checkin-data'; // GET
  static const String bookingsConfirmed = '/bookings/confirmed'; // GET

  // Tenants (manual walk-in)
  static const String tenantsManual = '/tenants/manual'; // POST

  // Staff
  static const String staff = '/staff'; // POST, GET, GET /{id}, PATCH /{id}, POST /{id}/activity

  // Documents
  static const String documents = '/documents'; // POST
  static const String documentsHostel = '/documents/hostel'; // GET /{hostelId}

  // Reviews
  static const String reviews = '/reviews'; // POST, GET /{id}
  static const String reviewsHostel = '/reviews/hostel'; // GET /{hostelId}

  // User Profile
  static const String userProfile = '/users/profile'; // GET, PUT
  static const String userCompleteProfile = '/users/complete-profile'; // POST
  static const String userDeleteAccount = '/users/delete-account'; // DELETE

  // User Hostels (public browsing)
  static const String userHostels = '/users/hostels'; // GET, GET /{id}

  // Formatting image URLs
  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http')) return path;

    // S3 Support: If the path contains the stay-india prefix, it's an S3 key
    if (path.startsWith('stay-india/')) {
      const String s3BucketUrl = 'https://stay-india.s3.us-east-1.amazonaws.com';
      return '$s3BucketUrl/$path';
    }

    // The server root is typically the baseUrl minus '/api'
    final String serverRoot = baseUrl.endsWith('/api') 
        ? baseUrl.substring(0, baseUrl.length - 4) 
        : baseUrl;

    // Normalize path separators and remove leading slash
    String cleanPath = path.replaceAll('\\', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // Prepend 'uploads/' only if not already present
    if (!cleanPath.startsWith('uploads/')) {
      cleanPath = 'uploads/$cleanPath';
    }

    return '$serverRoot/$cleanPath';
  }

  static String getPlaceholderImageUrl(String? path, {String text = 'Accommodation'}) {
    final url = getImageUrl(path);
    if (url != null) return url;
    return "https://placehold.co/600x400/png?text=$text";
  }
}
