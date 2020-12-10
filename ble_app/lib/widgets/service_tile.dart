import 'package:ble_app/widgets/characteristic_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

// Original: https://github.com/pauldemarco/flutter_blue/blob/8c615f7f6f00225f99f301cfe7670608ad78cc43/example/lib/widgets.dart#L123
class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({
    Key key,
    this.service,
    this.characteristicTiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.length > 0) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Service'),
            Text(
              '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).textTheme.caption.color,
                  ),
            )
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: Text('Service'),
        subtitle: Text(
          '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
        ),
      );
    }
  }
}
