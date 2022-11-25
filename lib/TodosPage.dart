import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  static const AdRequest request = AdRequest(
    nonPersonalizedAds: true,
  );
  RewardedAd? _rewardedAd;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: "ca-app-pub-3940256099942544/5224354917",
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedAd = null;
          },
        ));
  }

  void _showRewardedAd(String uid) {
    if (_rewardedAd == null) {
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          db.collection("users").doc(uid).update({"no_todos": 3});
        });
    _rewardedAd = null;
  }

  @override
  void initState() {
    super.initState();
    _createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    final titleTextController = TextEditingController();
    final descTextController = TextEditingController();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where("email", isEqualTo: user.email).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        var data = snapshot.data?.docs.first;
        return Scaffold(
            appBar: AppBar(
              title: const Text('My TODOs'),
              actions: [
                IconButton(
                    onPressed: signOut,
                    icon: const Icon(Icons.logout)
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                if(!(data?['no_todos']>0)) {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Add Todo'),
                      content: const Text("You run out of your todo entries, do you want to watch an ad for 3 more?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: (){
                            _showRewardedAd(data!.id);
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Add Todo'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleTextController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                          ),
                          TextField(
                            controller: descTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Description',
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: (){
                            final todo = <String, dynamic>{
                              "uid": data?['uid'],
                              "title": titleTextController.text.trim(),
                              "desc": descTextController.text.trim(),
                              "isDone": false
                            };
                            db.collection("todos").add(todo);
                            int todosLeft = data?['no_todos']-1;
                            db.collection("users").doc(data?.id).update({"no_todos": todosLeft});
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('todos').where("uid", isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return Column(
                    children: [
                      Center(child: Text("Hello ${data?['login']} ${data?['no_todos']}")),
                      Expanded(
                        child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                            return CheckboxListTile(
                              title: Text(data['title']),
                              subtitle: Text(data['desc']),
                              value: data['isDone'],
                              onChanged: (a) => db.collection("todos").doc(document.id).update({"isDone": a}),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => db.collection("todos").doc(document.id).delete(),
                                color: Colors.red,
                              ),
                            );
                          })
                              .toList()
                              .cast(),
                        ),
                      )
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }
              }
            )
        );
      }
    );
  }
}
