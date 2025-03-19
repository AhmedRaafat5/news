import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_api_service.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  final TextEditingController _searchController = TextEditingController();
  Future<List<NewsArticle>>? _searchFuture;
  bool _isSearching = false;

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchFuture = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchFuture = _newsApiService.searchNews(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchFuture = null;
                });
              },
            ),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: _performSearch,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _searchFuture == null
                ? const Center(
              child: Text('Enter a search term to find news'),
            )
                : FutureBuilder<List<NewsArticle>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Error searching news'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _performSearch(_searchController.text),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No results found'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return NewsCard(article: snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}