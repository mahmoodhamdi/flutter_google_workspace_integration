import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_apis_flutter/core/utils/logger/logger.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps a [child] with a biometric prompt that must succeed before the
/// child renders. Skips the prompt if the device has no biometric capability
/// or the user has explicitly disabled it.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({
    super.key,
    required this.child,
    this.enabled = true,
    this.reason = 'Unlock to access your workspace',
  });

  final Widget child;
  final bool enabled;
  final String reason;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _unlocked = false;
  bool _attempting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
    } else {
      _unlocked = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Re-lock on background.
      if (widget.enabled) setState(() => _unlocked = false);
    } else if (state == AppLifecycleState.resumed &&
        widget.enabled &&
        !_unlocked) {
      _tryUnlock();
    }
  }

  Future<void> _tryUnlock() async {
    if (_attempting) return;
    _attempting = true;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      if (!canCheck || !supported) {
        if (!mounted) return;
        setState(() => _unlocked = true);
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: widget.reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (!mounted) return;
      setState(() => _unlocked = ok);
    } catch (e, st) {
      appLog.w('BiometricGate: auth failed', error: e, stackTrace: st);
      if (mounted) setState(() => _unlocked = true);
    } finally {
      _attempting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Locked'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _tryUnlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
