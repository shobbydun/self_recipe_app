import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection of notes
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection("recipes");

  //create -> adding new note
  Future<void> addRecipe(String recipe) {
    return recipes.add({
      'recipe': recipe,
      'timestamp': Timestamp.now(),
    });
  }

  //read - get notes from db
  Stream<QuerySnapshot> getNotesStream() {
    final recipeStream =
        recipes.orderBy('timestamp', descending: true).snapshots();

    return recipeStream;
  }

  //update notes given a doc id
  Future<void> updateRecipe(String docID, String newRecipe) {
    return recipes.doc(docID).update(
      {'recipe': newRecipe, 'timestamp': Timestamp.now()},
    );
  }

  //delete notes given a doc id
  Future<void> deleteRecipe(String docID){
    return recipes.doc(
      docID
    ).delete();
  }
}
