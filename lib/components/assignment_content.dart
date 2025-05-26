import 'package:desktop_app/components/button.dart';
import 'package:desktop_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:desktop_app/models/sublevel_model.dart';
import 'package:webview_windows/webview_windows.dart';

class AssignmentContent extends StatefulWidget {
  final Assignment assignment;

  const AssignmentContent({super.key, required this.assignment});

  @override
  State<AssignmentContent> createState() => _AssignmentContentState();
}

class _AssignmentContentState extends State<AssignmentContent> {
  final _controller = WebviewController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(AssignmentContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assignment.id != widget.assignment.id) {
      _initWebView();
    }
  }

  Future<void> _initWebView() async {
    setState(() {
      _isLoading = true;
    });
    await _controller.initialize();
    await _controller.loadUrl(getAssignmentIframeUrl(widget.assignment.id));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                onPressed: () {
                  // TODO: Implement "Do later" functionality
                },
                isLoading: false,
                text: 'Do later',
                icon: Icons.do_not_touch,
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: () {
                  // TODO: Implement "Open editor" functionality
                },
                isLoading: false,
                text: 'Open editor',
                icon: Icons.open_in_new,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(child: Webview(_controller)),
        ],
      ),
    );
  }
}
