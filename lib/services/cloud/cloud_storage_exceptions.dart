class CloudStorageException implements Exception {
  const CloudStorageException();
}

// cloud note exceptions
class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}

class CouldNotAddImageToNoteException extends CloudStorageException {}

class CouldNotDeletImageException extends CloudStorageException {}

// cloud todo exceptions
class CouldNotGetAllTodosException extends CloudStorageException {}

class CouldNotCreateTodoException extends CloudStorageException {}

class CouldNotUpdateTodoException extends CloudStorageException {}

class CouldNotDeleteTodoException extends CloudStorageException {}
