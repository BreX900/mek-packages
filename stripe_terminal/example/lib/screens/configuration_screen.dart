import 'dart:async';

import 'package:example/utils/linear_progress_indicator_bar.dart';
import 'package:example/utils/state_tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final ValueListenable<PaymentStatus> paymentStatusListenable;
  final ValueListenable<Reader?> connectedReaderListenable;

  const ConfigurationScreen({
    super.key,
    required this.paymentStatusListenable,
    required this.connectedReaderListenable,
  });

  @override
  State<ConfigurationScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<ConfigurationScreen> with StateTools {
  TapToPayUxConfigurationTapZoneIndicator _indicator =
      TapToPayUxConfigurationTapZoneIndicator.below;
  double _xBias = 0.5;
  double _yBias = 0.5;
  int _primaryColor = 0xFF0000FF;
  int _successColor = 0xFF00FF00;
  int _errorColor = 0xFFFF0000;
  TapToPayUxConfigurationDarkMode _darkMode = TapToPayUxConfigurationDarkMode.system;

  Future<void> _setConfig() async {
    await Terminal.instance.setTapToPayUXConfiguration(
      TapToPayUxConfiguration(
        tapZone: TapToPayUxConfigurationTapZone(
          indicator: _indicator,
          position: TapToPayUxConfigurationTapZonePosition(
            xBias: _xBias,
            yBias: _yBias,
          ),
        ),
        colors: TapToPayUxConfigurationColorScheme(
          primary: _primaryColor,
          success: _successColor,
          error: _errorColor,
        ),
        darkMode: _darkMode,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Configured!'),
    ));
  }

  Widget _buildConfigForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<TapToPayUxConfigurationTapZoneIndicator>(
          value: _indicator,
          decoration: const InputDecoration(labelText: 'Tap Zone Indicator'),
          items: TapToPayUxConfigurationTapZoneIndicator.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last)))
              .toList(),
          onChanged: (v) => setState(() => _indicator = v!),
        ),
        if (_indicator == TapToPayUxConfigurationTapZoneIndicator.front ||
            _indicator == TapToPayUxConfigurationTapZoneIndicator.behind) ...[
          const SizedBox(height: 16),
          Text('Tap Zone X Bias: ${_xBias.toStringAsFixed(2)}'),
          Slider(
            value: _xBias,
            divisions: 100,
            label: _xBias.toStringAsFixed(2),
            onChanged: (v) => setState(() => _xBias = v),
          ),
          const SizedBox(height: 16),
          Text('Tap Zone Y Bias: ${_yBias.toStringAsFixed(2)}'),
          Slider(
            value: _yBias,
            divisions: 100,
            label: _yBias.toStringAsFixed(2),
            onChanged: (v) => setState(() => _yBias = v),
          ),
        ],
        const SizedBox(height: 16),
        _ColorPickerField(
          label: 'Primary Color',
          color: _primaryColor,
          onColorChanged: (color) => setState(() => _primaryColor = color),
        ),
        _ColorPickerField(
          label: 'Success Color',
          color: _successColor,
          onColorChanged: (color) => setState(() => _successColor = color),
        ),
        _ColorPickerField(
          label: 'Error Color',
          color: _errorColor,
          onColorChanged: (color) => setState(() => _errorColor = color),
        ),
        DropdownButtonFormField<TapToPayUxConfigurationDarkMode>(
          value: _darkMode,
          decoration: const InputDecoration(labelText: 'Dark Mode'),
          items: TapToPayUxConfigurationDarkMode.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last)))
              .toList(),
          onChanged: (v) => setState(() => _darkMode = v!),
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () => mutate(_setConfig),
          child: const Text('Set Config'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectedReader = ref.watch(widget.connectedReaderListenable);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        bottom: isMutating ? const LinearProgressIndicatorBar() : null,
      ),
      body: connectedReader == null
          ? const Center(child: Text('No reader connected.'))
          : connectedReader.deviceType == DeviceType.tapToPay
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildConfigForm(),
                  ),
                )
              : Center(
                  child: Text(
                      'Connected reader is not a Tap to Pay reader. Type: ${connectedReader.deviceType}'),
                ),
    );
  }
}

class _ColorPickerField extends StatefulWidget {
  final String label;
  final int color;
  final ValueChanged<int> onColorChanged;

  const _ColorPickerField({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<_ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<_ColorPickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.color.toRadixString(16));
  }

  @override
  void didUpdateWidget(covariant _ColorPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _controller.text = widget.color.toRadixString(16);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(labelText: '${widget.label} (hex)'),
            onChanged: (v) {
              final value = int.tryParse(v, radix: 16);
              if (value != null) widget.onColorChanged(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            var pickerColor = Color(widget.color);
            final pickedColor = await showDialog<Color>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pick ${widget.label}'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                      onColorChanged: (c) {
                        pickerColor = c;
                      },
                      hexInputBar: true,
                      pickerColor: pickerColor),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(pickerColor),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            if (pickedColor != null) {
              widget.onColorChanged(pickedColor.toARGB32());
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(widget.color),
              border: Border.all(),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
