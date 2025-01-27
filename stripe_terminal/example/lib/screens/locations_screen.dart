import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:flutter/material.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  final ValueNotifier<Location?> locationNotifier;

  const LocationsScreen({
    super.key,
    required this.locationNotifier,
  });

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> with StateTools {
  var _locations = <Location>[];

  Future<void> _fetchLocations() async {
    setState(() => _locations = const []);
    final locations = await Terminal.instance.listLocations();
    setState(() => _locations = locations);
  }

  void _toggleLocation(Location location) {
    final selectedLocation = widget.locationNotifier.value;
    widget.locationNotifier.value = selectedLocation == location ? null : location;
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(widget.locationNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FilledButton.tonal(
              onPressed: !isMutating ? () => mutate(_fetchLocations) : null,
              child: const Text('Fetch Locations'),
            ),
            const Divider(height: 32.0),
            ..._locations.map((e) {
              return ListTile(
                selected: selectedLocation?.id == e.id,
                onTap: () => _toggleLocation(e),
                dense: true,
                title: Text('${e.id}: ${e.displayName}'),
                subtitle: Text('${e.address?.city},${e.address?.state},${e.address?.line1}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
