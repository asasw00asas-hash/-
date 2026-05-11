import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webview_screen.dart';

class AutoReplyRule {
  final String keyword;
  final String reply;

  AutoReplyRule({required this.keyword, required this.reply});

  Map<String, String> toJson() => {'keyword': keyword, 'reply': reply};
  factory AutoReplyRule.fromJson(Map<String, dynamic> json) =>
      AutoReplyRule(keyword: json['keyword'], reply: json['reply']);
}

class AutoReplyScreen extends StatefulWidget {
  const AutoReplyScreen({super.key});

  @override
  State<AutoReplyScreen> createState() => _AutoReplyScreenState();
}

class _AutoReplyScreenState extends State<AutoReplyScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  List<AutoReplyRule> _rules = [];
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rulesJson = prefs.getString('auto_reply_rules');
    if (rulesJson != null) {
      final List<dynamic> decoded = jsonDecode(rulesJson);
      setState(() {
        _rules = decoded.map((item) => AutoReplyRule.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveRules() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_rules.map((e) => e.toJson()).toList());
    await prefs.setString('auto_reply_rules', encoded);
  }

  void _addRule() {
    if (_keywordController.text.isNotEmpty && _replyController.text.isNotEmpty) {
      setState(() {
        _rules.add(AutoReplyRule(
          keyword: _keywordController.text.trim().toLowerCase(),
          reply: _replyController.text.trim(),
        ));
        _keywordController.clear();
        _replyController.clear();
      });
      _saveRules();
      if (_isActive) _startAutoReplyEngine(); // Re-inject with new rules
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
    _saveRules();
  }

  /// Injects the JavaScript Auto-Reply Engine into the WebView.
  Future<void> _startAutoReplyEngine() async {
    if (WebviewScreen.webViewController == null) return;

    final String rulesJson = jsonEncode(_rules.map((e) => e.toJson()).toList());
    
    final String jsCode = """
      (function() {
        if (window.autoReplyInterval) clearInterval(window.autoReplyInterval);
        
        const rules = $rulesJson;
        console.log("Auto-Reply Engine Started with rules:", rules);

        window.autoReplyInterval = setInterval(() => {
          // 1. Look for unread message badges
          const unreadBadge = document.querySelector('span[aria-label*="unread"], span[data-icon="unread-count"]');
          
          if (unreadBadge) {
            console.log("Unread message detected, clicking...");
            const chatElement = unreadBadge.closest('div[role="listitem"]');
            if (chatElement) {
              chatElement.click();
              
              // 2. Wait for chat to open and check last message
              setTimeout(() => {
                const messagesIn = document.querySelectorAll('.message-in .selectable-text');
                if (messagesIn.length > 0) {
                  const lastMsgText = messagesIn[messagesIn.length - 1].innerText.toLowerCase().trim();
                  console.log("Last received message: " + lastMsgText);
                  
                  // 3. Match keyword
                  const match = rules.find(r => lastMsgText.includes(r.keyword.toLowerCase()));
                  
                  if (match) {
                    console.log("Match found! Replying with: " + match.reply);
                    const input = document.querySelector('div[contenteditable="true"][data-tab="10"]');
                    if (input) {
                      input.innerText = match.reply;
                      input.dispatchEvent(new Event('input', { bubbles: true }));
                      
                      setTimeout(() => {
                        const sendBtn = document.querySelector('span[data-icon="send"]');
                        if (sendBtn) sendBtn.click();
                      }, 500);
                    }
                  }
                }
              }, 1500);
            }
          }
        }, 3000); // Poll every 3 seconds
      })();
    """;

    await WebviewScreen.webViewController?.evaluateJavascript(source: jsCode);
    setState(() => _isActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto-Reply Engine Active!')),
    );
  }

  void _stopAutoReplyEngine() {
    WebviewScreen.webViewController?.evaluateJavascript(source: "if(window.autoReplyInterval) clearInterval(window.autoReplyInterval);");
    setState(() => _isActive = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto-Reply Engine Stopped.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020512),
      appBar: AppBar(
        title: const Text('Auto-Reply System'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Engine Control
            _buildGlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Engine Status', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_isActive ? 'ACTIVE' : 'INACTIVE', 
                        style: TextStyle(color: _isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: _isActive,
                    activeColor: const Color(0xFF00BFFF),
                    onChanged: (val) => val ? _startAutoReplyEngine() : _stopAutoReplyEngine(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rule Entry
            _buildGlassContainer(
              child: Column(
                children: [
                  TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(labelText: 'If message contains (Keyword)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(labelText: 'Reply with...'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addRule,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFFF), foregroundColor: Colors.white),
                      child: const Text('Add Rule'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rules List
            Expanded(
              child: ListView.builder(
                itemCount: _rules.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text('If: "${_rules[index].keyword}"', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Reply: "${_rules[index].reply}"'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeRule(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
