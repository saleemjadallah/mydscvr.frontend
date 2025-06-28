import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Error boundary widget to catch and handle exceptions
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? fallbackMessage;
  final VoidCallback? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallbackMessage,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // Catch Flutter errors
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _error = details.exception;
          _stackTrace = details.stack;
        });
        
        // Log the error
        print('🚨 ErrorBoundary caught Flutter error: ${details.exception}');
        print('🚨 Stack trace: ${details.stack}');
        
        widget.onError?.call();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget(context);
    }

    // Wrap child with error catching
    return _SafeChild(
      child: widget.child,
      onError: (error, stackTrace) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _error = error;
            _stackTrace = stackTrace;
          });
          
          print('🚨 ErrorBoundary caught error: $error');
          print('🚨 Stack trace: $stackTrace');
          
          widget.onError?.call();
        }
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            widget.fallbackMessage ?? 'Something went wrong',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (kDebugMode && _error != null) ...[
            Text(
              'Error: $_error',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _error = null;
                  _stackTrace = null;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SafeChild extends StatelessWidget {
  final Widget child;
  final Function(Object error, StackTrace stackTrace) onError;

  const _SafeChild({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      return const SizedBox.shrink();
    }
  }
}