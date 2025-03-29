import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/workout_model.dart';
import '../services/workout_storage_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.workout});
  
  final WorkoutModel workout;

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final date = workout.startTime.toLocal();
    final formattedDate = '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Workout Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Date display
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Distance display
                    const Text(
                      'DISTANCE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(workout.totalDistance / 1000).toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('PACE', workout.formattedPace),
                        _buildStatColumn('TIME', _formatDuration(workout.duration)),
                        _buildStatColumn('CALORIES', '${workout.caloriesBurned}'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Route Map
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildRouteMap(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Route summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ROUTE SUMMARY',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GPS Points: ${workout.route.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Started: ${_formatDateTime(workout.startTime)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.stop_circle_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ended: ${_formatDateTime(workout.endTime)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.save,
                  'SAVE',
                  () async {
                    // Capture context before async gap
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    // Save workout to history
                    final storageService = WorkoutStorageService();
                    final saved = await storageService.saveWorkout(workout);
                    
                    // Use captured context reference
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(saved 
                          ? 'Workout saved to history' 
                          : 'Failed to save workout'),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  Icons.share,
                  'SHARE',
                  () {
                    // Share workout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing not implemented yet')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  Widget _buildRouteMap() {
    // Convert route to LatLng list for Google Maps
    final latLngRoute = workout.toLatLngList();
    
    // Default to Tokyo if no route points available
    final initialPosition = latLngRoute.isNotEmpty 
        ? latLngRoute.first 
        : const LatLng(35.6812, 139.7671); // Tokyo coordinates as fallback
    
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15.0,
      ),
      polylines: {
        Polyline(
          polylineId: const PolylineId('workout_route'),
          color: Colors.blue,
          width: 4,
          points: latLngRoute,
        ),
      },
      markers: {
        if (latLngRoute.isNotEmpty)
          Marker(
            markerId: const MarkerId('start_point'),
            position: latLngRoute.first,
            infoWindow: const InfoWindow(title: 'Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        if (latLngRoute.length > 1)
          Marker(
            markerId: const MarkerId('end_point'),
            position: latLngRoute.last,
            infoWindow: const InfoWindow(title: 'Finish'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
      },
      myLocationEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
    );
  }
}
