import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:time_teller_app/pages/inspirations/widgets/inspiration_card.dart';

class InspirationsPage extends StatefulWidget {
  const InspirationsPage({super.key});

  @override
  State<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends State<InspirationsPage> {
  final TextEditingController _quoteController = TextEditingController();
  List<String> _quotes = [];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _quoteController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quotes = prefs.getStringList('quotes') ?? [];
    });
  }

  Future<void> _saveQuote() async {
    if (_quoteController.text.trim().isEmpty) {
      print('Quote is empty'); // Debug print
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final quote = _quoteController.text.trim(); // Store trimmed quote
    
    setState(() {
      _quotes.add(quote);
      _quoteController.clear();
    });
    
    // Move SharedPreferences update outside setState
    await prefs.setStringList('quotes', _quotes);
    print('Quote saved: $quote'); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspirations'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // text input for inspiration
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _quoteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your inspiration words',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            // button to save inspiration
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _saveQuote,
                child: Text('Add quote'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 20,),
                  SizedBox(width: 10,),
                  Text('Your current inspirations:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.start,),
                ],
              ),
            ),

            // list of inspirations
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 450,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_quotes[index]),
                      onDismissed: (direction) async {
                        final deletedQuote = _quotes[index];
                        setState(() {
                          _quotes.removeAt(index);
                        });
                        
                        // Update SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList('quotes', _quotes);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Quote deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                setState(() {
                                  _quotes.insert(index, deletedQuote);
                                });
                                await prefs.setStringList('quotes', _quotes);
                              },
                            ),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: InspirationCard(
                        quote: _quotes[index],
                        onDelete: () async {
                          final deletedQuote = _quotes[index];
                          setState(() {
                            _quotes.removeAt(index);
                          });
                          
                          // Update SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setStringList('quotes', _quotes);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Quote deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  setState(() {
                                    _quotes.insert(index, deletedQuote);
                                  });
                                  await prefs.setStringList('quotes', _quotes);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
