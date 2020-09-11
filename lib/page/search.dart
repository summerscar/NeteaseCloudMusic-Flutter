import 'dart:developer';

import 'package:flutter/material.dart';
import '../utils/api.dart';
import 'package:dio/dio.dart';
import '../state/state.dart';
import 'package:provider/provider.dart';

// Defines the content of the search page in `showSearch()`.
// SearchDelegate has a member `query` which is the query string.
class MySearchDelegate extends SearchDelegate<dynamic> {
  StateModel state;
  MySearchDelegate(BuildContext context)
      : state = context.read<StateModel>(),
        super();

  Future _fetchPosts() async {
    List<dynamic> reslut;
    Response response;
    if (this.query == '') return [];

    try {
      response = await api().get('/search?keywords=${this.query}');
      if (response.data['code'] == 200 &&
          response.data['result']['songCount'] > 0) {
        reslut = response.data['result']['songs'];
      } else {
        reslut = [];
      }
    } catch (e) {
      print(e);
    }
    return reslut;
  }

  // Leading icon in search bar.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        // SearchDelegate.close() can return vlaues, similar to Navigator.pop().
        this.close(context, null);
      },
    );
  }

  // Widget of result page.
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: _fetchPosts(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final post = snapshot.data;
          return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(post[index]['name']),
                  subtitle: Text(post[index]['artists']
                      .map((artist) => artist['name'])
                      .join(' / ')),
                  onTap: () {
                    state.playSongOrigin(post[index]);
                    this.close(context, null);
                  },
                  trailing: IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () => state.addSongOrigin(post[index])),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: Colors.black12,
                  thickness: 1,
                );
              },
              itemCount: post.length);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // Suggestions list while typing (this.query).
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: _fetchPosts(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final post = snapshot.data;

          return _SuggestionList(
            query: this.query,
            suggestions: this.query.isEmpty ? Provider.of<StateModel>(context, listen: true).searchHistory : post,
            onSelected: (String suggestion) {
              this.query = suggestion;
              state.addSearchHistory(suggestion);
              showResults(context);
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? SizedBox()
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

// Suggestions list widget displayed in the search page.
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<dynamic> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // new,
        itemCount: query.isEmpty ? suggestions.length + 1 : suggestions.length,
        itemBuilder: (BuildContext context, int i) {
          dynamic suggestion;
          if (i == suggestions.length) {
            return ListTile(
              title: Center(child: Text('清空历史'),),
              onTap: () {
                Provider.of<StateModel>(context, listen: false)
                  .setSearchHistory([]);
              },
            );
          } else {
            suggestion = suggestions[i];
            return ListTile(
              leading: query.isEmpty ? Icon(Icons.history) : SizedBox(width: 0),
              // Highlight the substring that matched the query.
              title: Text(query.isEmpty ? suggestion : suggestion['name']),
              onTap: () {
                onSelected(query.isEmpty ? suggestion : suggestion['name']);
              },
            );
          }
        });
  }
}
