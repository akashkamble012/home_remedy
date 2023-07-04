import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RemediesDetailPage extends StatefulWidget {
  Map<String, dynamic> remedyData;
  final String userId;
  final bool showVoting;

  RemediesDetailPage({required this.remedyData, required this.userId, this.showVoting = true});

  @override
  _RemediesDetailPageState createState() => _RemediesDetailPageState();
}

class _RemediesDetailPageState extends State<RemediesDetailPage> {
  bool votedEffective = false;
  bool votedNotEffective = false;

  @override
  void initState() {
    super.initState();
    checkVoteStatus();
  }

  void checkVoteStatus() {
    final votes = widget.remedyData['votes'];
    final userId = widget.userId;

    if (votes['effective']['users'].contains(userId)) {
      setState(() {
        votedEffective = true;
      });
    } else if (votes['notEffective']['users'].contains(userId)) {
      setState(() {
        votedNotEffective = true;
      });
    }
  }

  void voteOnRemedy(String remedyId, String userId, String voteCategory) {
    final voteCountField = 'votes.$voteCategory.count';
    final voteUsersField = 'votes.$voteCategory.users';

    FirebaseFirestore.instance
        .collection('remedies')
        .doc(remedyId)
        .get()
        .then((snapshot) {
      final votes = snapshot.data()?['votes'];
      final previousCategory = getPreviousVoteCategory(votes, userId);

      FirebaseFirestore.instance.collection('remedies').doc(remedyId).update({
        voteCountField: FieldValue.increment(1),
        voteUsersField: FieldValue.arrayUnion([userId]),
      }).then((value) {
        if (previousCategory != null && previousCategory != voteCategory) {
          final previousVoteUsersField = 'votes.$previousCategory.users';
          FirebaseFirestore.instance
              .collection('remedies')
              .doc(remedyId)
              .update({
            previousVoteUsersField: FieldValue.arrayRemove([userId]),
          }).then((value) {
            if (kDebugMode) {
              print('Previous vote removed successfully');
            }
            updateEffectivenessValue(remedyId);
            fetchRemedy(remedyId);
          }).catchError((error) {
            print('Error removing previous vote: $error');
          });
        } else {
          print('Vote recorded successfully');
          updateEffectivenessValue(remedyId);
          fetchRemedy(remedyId);
        }
      }).catchError((error) {
        print('Error recording vote: $error');
      });
    }).catchError((error) {
      print('Error fetching remedy: $error');
    });
  }

  Future<void> updateEffectivenessValue(String remedyId) async {
    final remedyRef =
        FirebaseFirestore.instance.collection('remedies').doc(remedyId);

    // Fetch the remedy document
    final remedyDoc = await remedyRef.get();
    final remedyData = remedyDoc.data() as Map<String, dynamic>;

    // Get the votes and calculate the percentages
    final votes = remedyData['votes'] as Map<String, dynamic>;
    final totalVotes =
        votes.values.fold(0, (sum, category) => sum + category['count'] as int);

    // Fetch the user collection and count the total number of users
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await userCollection.get();
    final totalUsers = userSnapshot.docs.length;

    // Define the threshold percentage
    final thresholdPercentage =
        0.6; // Set your desired threshold percentage here

    // Calculate the threshold number of votes
    final thresholdVotes = (totalVotes * thresholdPercentage).floor();

    // Calculate the combined percentage of all categories
    double combinedPercentage = 0.0;
    for (final entry in votes.entries) {
      final categoryVotes = entry.value['count'] as int;
      final categoryPercentage = categoryVotes / totalVotes;
      combinedPercentage += categoryPercentage;
    }

    // Check if the combined percentage exceeds the threshold
    if (combinedPercentage >= thresholdPercentage) {
      final highestVoteCategory = votes.entries
          .reduce((a, b) => a.value['count'] > b.value['count'] ? a : b)
          .key;
      remedyRef.update({'effectiveness': highestVoteCategory});
    }
  }

  String? getPreviousVoteCategory(Map<String, dynamic>? votes, String userId) {
    if (votes != null) {
      if (votes['effective']['users'].contains(userId)) {
        return 'effective';
      } else if (votes['notEffective']['users'].contains(userId)) {
        return 'notEffective';
      } else if (votes['unknown']['users'].contains(userId)) {
        return 'unknown';
      }
    }
    return null;
  }

  void vote(String voteCategory) {
    final remedyId = widget.remedyData['remedyId'];
    final userId = widget.userId;

    if (voteCategory == 'effective' && votedEffective) {
      // Remove user's vote if already voted as effective
      setState(() {
        votedEffective = false;
      });
      voteOnRemedy(remedyId, userId, 'unknown');
    } else if (voteCategory == 'notEffective' && votedNotEffective) {
      // Remove user's vote if already voted as notEffective
      setState(() {
        votedNotEffective = false;
      });
      voteOnRemedy(remedyId, userId, 'unknown');
    } else {
      // Vote for the selected category
      setState(() {
        if (voteCategory == 'effective') {
          votedEffective = true;
          votedNotEffective = false;
        } else if (voteCategory == 'notEffective') {
          votedEffective = false;
          votedNotEffective = true;
        }
      });
      voteOnRemedy(remedyId, userId, voteCategory);
    }
  }

  void fetchRemedy(String remedyId) {
    FirebaseFirestore.instance
        .collection('remedies')
        .doc(remedyId)
        .get()
        .then((snapshot) {
      setState(() {
        widget.remedyData = snapshot.data() as Map<String, dynamic>;
      });
      checkVoteStatus();
      print('Remedy fetched successfully');
    }).catchError((error) {
      print('Error fetching remedy: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.remedyData['title'];
    final symptoms = List<String>.from(widget.remedyData['symptoms']);
    final ingredients = List<String>.from(widget.remedyData['ingredients']);
    final instructions = widget.remedyData['instructions'];
    final note = widget.remedyData['note'];
    final effectiveness = widget.remedyData['effectiveness'];
    final userId = widget.remedyData['userId'];

    ElevatedButton effectiveButton = ElevatedButton.icon(
      onPressed: () => vote('effective'),
      icon: votedEffective
          ? const Icon(Icons.thumb_up_alt_rounded, color: Colors.green)
          : const Icon(Icons.thumb_up_alt_rounded, color: Colors.white),
      label: const Text('Effective'),
    );

    ElevatedButton notEffectiveButton = ElevatedButton.icon(
      onPressed: () => vote('notEffective'),
      icon: votedNotEffective
          ? const Icon(Icons.thumb_down_alt_rounded, color: Colors.red)
          : const Icon(Icons.thumb_down_alt_rounded, color: Colors.white),
      label: const Text('Not Effective'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Symptoms:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  symptoms.join(", "),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingredients:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ingredients.join(", "),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructions,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Effectiveness:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  effectiveness,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                if(widget.showVoting)
                const Text(
                  'Vote:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if(widget.showVoting)
                  const SizedBox(height: 8),
                if(widget.showVoting)
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    effectiveButton,
                    notEffectiveButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
