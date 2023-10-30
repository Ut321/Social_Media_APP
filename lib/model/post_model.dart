class Post {
  String imageUrl;
  String caption;
  Set<String> likedBy; // Set to store user IDs who have liked the post

  // Constructor initializing the 'likedBy' set
  Post({
    required this.imageUrl,
    required this.caption,
    Set<String>? likedBy,
  }) : likedBy = likedBy ??
            {}; // Initialize likedBy set, defaulting to an empty set if null

  // Getter for the 'likes' count based on the size of 'likedBy' set
  int get likes => likedBy.length;

  // Method to toggle like status for a user
  void toggleLike(String userId) {
    if (likedBy.contains(userId)) {
      // User already liked the post, cancel the like
      likedBy.remove(userId);
    } else {
      // User has not liked the post, add like
      likedBy.add(userId);
    }
  }
}
