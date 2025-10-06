import 'package:devtools_plus/tools/epoch_converter/epoch_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EpochConverterScreen extends StatefulWidget {
  const EpochConverterScreen({super.key});

  @override
  State<EpochConverterScreen> createState() => _EpochConverterScreenState();
}

class _EpochConverterScreenState extends State<EpochConverterScreen> {
  final _service = EpochService();
  final _epochController = TextEditingController();
  final _isoController = TextEditingController();
  final _outputController = TextEditingController();
  
  bool _isMilliseconds = true;
  String _conversionMode = 'epochToIso';

  @override
  void initState() {
    super.initState();
    _setCurrentTime();
  }

  void _setCurrentTime() {
    final now = _service.nowEpoch(inMilliseconds: _isMilliseconds);
    setState(() {
      _epochController.text = now.toString();
    });
    _convert();
  }

  void _convert() {
    try {
      String result = '';
      
      switch (_conversionMode) {
        case 'epochToIso':
          final timestamp = int.parse(_epochController.text);
          result = _service.epochToIso(timestamp, isMilliseconds: _isMilliseconds);
          break;
        case 'epochToDetails':
          final timestamp = int.parse(_epochController.text);
          final details = _service.epochToDetails(timestamp, isMilliseconds: _isMilliseconds);
          result = 'ISO 8601: ${details['iso8601']}\n'
              'UTC: ${details['utc']}\n'
              'Local: ${details['local']}\n'
              'Year: ${details['year']}\n'
              'Month: ${details['month']}\n'
              'Day: ${details['day']}\n'
              'Hour: ${details['hour']}\n'
              'Minute: ${details['minute']}\n'
              'Second: ${details['second']}\n'
              'Weekday: ${details['weekday']}\n'
              'Timezone: ${details['timezone']}';
          break;
        case 'isoToEpoch':
          result = _service.isoToEpoch(_isoController.text, inMilliseconds: _isMilliseconds).toString();
          break;
      }
      
      setState(() {
        _outputController.text = result;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: Invalid input - ${e.toString()}';
      });
    }
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Epoch/Time Converter',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'epochToIso',
                  label: Text('Epoch → ISO'),
                  icon: Icon(Icons.arrow_forward),
                ),
                ButtonSegment(
                  value: 'epochToDetails',
                  label: Text('Epoch → Details'),
                  icon: Icon(Icons.info_outline),
                ),
                ButtonSegment(
                  value: 'isoToEpoch',
                  label: Text('ISO → Epoch'),
                  icon: Icon(Icons.arrow_back),
                ),
              ],
              selected: {_conversionMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _conversionMode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Use Milliseconds'),
              subtitle: Text(_isMilliseconds ? 'Timestamps in milliseconds' : 'Timestamps in seconds'),
              value: _isMilliseconds,
              onChanged: (value) {
                setState(() {
                  _isMilliseconds = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_conversionMode == 'epochToIso' || _conversionMode == 'epochToDetails') ...[
              TextField(
                controller: _epochController,
                decoration: InputDecoration(
                  labelText: 'Epoch Timestamp',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.update),
                    tooltip: 'Set to current time',
                    onPressed: _setCurrentTime,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              TextField(
                controller: _isoController,
                decoration: const InputDecoration(
                  labelText: 'ISO 8601 String',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: '2024-01-01T12:00:00Z',
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.transform),
              label: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Output',
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _outputController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _epochController.dispose();
    _isoController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
