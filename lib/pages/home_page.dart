import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:self_recipe_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Accessing firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Text controller to access what the user has written
  final TextEditingController textController = TextEditingController();

  // Function to open show dialog
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Recipe'),
        content: TextField(
          controller: textController,
          maxLines: null, // Allows for multiple lines of text
          decoration: InputDecoration(
            hintText: 'Enter recipe details...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Adding a new recipe
              if (docID == null) {
                firestoreService.addRecipe(textController.text);
              } 
              // Updating existing recipe
              else {
                firestoreService.updateRecipe(docID, textController.text);
              }

              // Clear text controller
              textController.clear();

              // Pop the dialog
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[400], // Background color of the Scaffold
      appBar: AppBar(
        elevation: 0,
        title: const Text("My Recipes 😋🍔"),
        backgroundColor: Colors.orange[800], // Custom AppBar color
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange[800], // FloatingActionButton color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // If we have data get all docs
          if (snapshot.hasData) {
            List recipeList = snapshot.data!.docs;

            // Display the list
            return ListView.builder(
              itemCount: recipeList.length,
              itemBuilder: (context, index) {
                // Get each individual doc
                DocumentSnapshot document = recipeList[index];
                String docID = document.id;

                // Get note from each doc
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String recipeText = data['recipe'];

                // Display as a list tile
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 136, 131, 243).withOpacity(0.9),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      recipeText,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.edit),
                          color: Colors.orange[800],
                        ),
                        // Delete button
                        IconButton(
                          onPressed: () => firestoreService.deleteRecipe(docID),
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } 
          // If there are no recipes yet
          else {
            return const Center(
              child: Text("No recipes yet 🙊🍕..."),
            );
          }
        },
      ),
    );
  }
}
