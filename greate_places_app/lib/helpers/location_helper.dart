

class LocationHelper {
  static String _gapi = "";

  static String generateLocationPreviewImage({double latitude, double longitude}) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$_gapi";
  }

  static Future<String> getPlaceAddress({double latitude, double longitude}) {
    final String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_gapi";

    // TODO: make http call to the API and get address

    return Future.value("TEsts address");
  }
}