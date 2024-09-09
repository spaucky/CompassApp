// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return CupertinoApp(
            theme: const CupertinoThemeData(
                primaryColor: CupertinoColors.black,
                textTheme: CupertinoTextThemeData(
                    textStyle: TextStyle(
                        color: CupertinoColors.black,
                        fontSize: 18.0
                    )
                )
            ),
            home: LocationSearch());
    }
}

class LocationSearch extends StatefulWidget {
    @override
    LocationSearchState createState() => LocationSearchState();
}

class LocationSearchState extends State<LocationSearch> {
  String _searchText = '';
  Timer? _debounceTimer;
  Future<List<dynamic>>? _searchFuture;

  void onSearchTextChange(String searchText) {
    //If debounceTimer is null or active then cancels it
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (searchText.length > 3) {
        _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
            //If no new input then sends off the text to the API
            setState(() {
                _searchFuture = locationAutocompleteRequest(searchText);
            });
        });
    }
  }
  
  Future<List<dynamic>> locationAutocompleteRequest(String searchText) async {
    const String apiUrl = 'https://api.locationiq.com/v1/autocomplete';
    const String apiKey = 'pk.02ae472ad46724cd96c905f283966fe6';

    try {
        final response = await http.get(Uri.parse('$apiUrl?q=$searchText&key=$apiKey'));

        if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            print(data);
            return (data);
        }
        else {
            return ([]);
        }
    }   catch (e) {
        return ([]);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Location Search'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CupertinoSearchTextField(
                placeholder: 'Where are you going?',
                style: const TextStyle(color: CupertinoColors.black),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  onSearchTextChange(_searchText);
                },
              ),
              const SizedBox(height: 20),
              // Use FutureBuilder to handle the asynchronous API request
              if (_searchText.isNotEmpty && _searchFuture != null)
                Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _searchFuture,  // Call the async function
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
                                  Text('Waiting for API Response', style: TextStyle(color: CupertinoColors.black))
                                ]));
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data!.isEmpty) {
                            return const Text('No data currently');
                        }
                        else if (snapshot.hasData) {
                          return Expanded(
                            child: CupertinoScrollbar(    
                                child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                    var address = snapshot.data![index]['address'];
                                    return Container( 
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [BoxShadow(
                                            color: CupertinoColors.systemGrey.withOpacity(0.5),
                                            blurRadius: 5.0,
                                            offset: const Offset(0, 2),
                                        )]
                                      ),
                                        child: CupertinoListTile(
                                            title: Text(
                                                // ignore: prefer_interpolation_to_compose_strings
                                                '${address['name'] == null ? '' : '${address['name']}'}' +
                                                '${address['road'] == null ? '' : ', ${address['road']}'}' +
                                                '${address['city'] == null ? '' : ', ${address['city']}'}',
                                                style: const TextStyle(color: CupertinoColors.black),
                                            ),
                                            onTap: () {
                                                // Add logic for when a user taps an item
                                                print('Selected: ${address['name']}');
                                            },
                                        ));
                                },
                                ),
                          ));
                        } else {
                          return const Text('No results found.');
                        }
                    },
                    )
                )
              else
                const Text('Enter a search query'),
            ],
          ),
        ),
      ),
    );
  }
}
/*
class LocationSearchState extends State<LocationSearch> {
    String _searchText = '';

    @override
    Widget build(BuildContext context) {
        return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
                middle: Text('Location Search'),
            ),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: <Widget>[
                        CupertinoSearchTextField(
                            placeholder: 'Where are you going?',
                            onChanged: (value) {
                                setState(() {
                                    _searchText = value;
                                });
                            },
                        ),
                        SizedBox(height: 20),
                        Expanded(
                            child: Center(
                                child: Text(
                                    _searchText.isEmpty ? 'No search query' : 'Searching...',
                                    style: TextStyle(fontSize: 16.0)
                                ),
                            ),
                        )
                    ],
                )
            )
        );
    }
}
*/