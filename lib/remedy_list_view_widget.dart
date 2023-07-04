import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/remedy_details.dart';
import 'package:home_remedy/remedy_search_delegate.dart';

class RemediesListView extends StatefulWidget {
  final List<Map<String, dynamic>> remedies;
  final Function? callback;

  const RemediesListView({Key? key, required this.remedies, this.callback})
      : super(key: key);

  @override
  _RemediesListViewState createState() => _RemediesListViewState();
}


class _RemediesListViewState extends State<RemediesListView> {
  List<Map<String, dynamic>> filteredRemedies = [];

  @override
  void initState() {
    super.initState();
    filteredRemedies = widget.remedies;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onTap: () {
              showSearch(
                  context: context,
                  delegate: RemediesSearchDelegate(widget.remedies));
            },
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRemedies.length,
            itemBuilder: (context, index) {
              final remedy = filteredRemedies[index];
              print(remedy);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    remedy['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Symptoms: ${remedy['symptoms'].join(' ')}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RemediesDetailPage(
                          remedyData: remedy,
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ),
                    );
                    widget.callback!();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}