@IsTest
public class BookInUserCollectionControllerTest {
    static BookInUserCollection__c setupTestData() {
        Genre__c testGenre = new Genre__c(Name = 'Fiction');
        insert testGenre;

        Book__c testBook = new Book__c(
            Name = 'Test Book',
            Genre__c = testGenre.Id,
            Number_of_pages__c = 300
        );
        insert testBook;

        BookInUserCollection__c bookInUserCollection = new BookInUserCollection__c(
            Book__c = testBook.Id,
            User__c = UserInfo.getUserId(),
            Reading_status__c = 'Pašlaik lasu',
            Current_page__c = 50,
            Times_read__c = 1
        );
        insert bookInUserCollection;

        return bookInUserCollection;
    }

    @IsTest
    static void testGetBooks_AllBooks() {
        setupTestData();

        Test.startTest();
        List<BookInUserCollection__c> books = BookInUserCollectionController.getBooks(null);
        Test.stopTest();

        System.assertNotEquals(null, books, 'Books should not be null.');
        System.assertEquals(1, books.size(), 'There should be one book in the user collection.');
    }

    @IsTest
    static void testGetBooks_ReadBooks() {
        BookInUserCollection__c book = setupTestData();
        book.Reading_status__c = 'Izlasīta';
        update book;

        Test.startTest();
        List<BookInUserCollection__c> books = BookInUserCollectionController.getBooks('readBooks');
        Test.stopTest();

        System.assertEquals(1, books.size(), 'There should be one read book.');
        System.assertEquals('Izlasīta', books[0].Reading_status__c, 'Reading status should be "Izlasīta".');
    }

    @IsTest
    static void testGetCurrentlyReadingBooks_Success() {
        setupTestData();

        Test.startTest();
        List<BookInUserCollection__c> books = BookInUserCollectionController.getCurrentlyReadingBooks();
        Test.stopTest();

        System.assertEquals(1, books.size(), 'There should be one book currently being read.');
        System.assertEquals(50, books[0].Current_page__c, 'Current page should match.');
    }

    @IsTest
    static void testGetCurrentlyReadingBooks_NoBooks() {
        setupTestData();

        BookInUserCollection__c book = [SELECT Id FROM BookInUserCollection__c LIMIT 1];
        book.Reading_status__c = 'Izlasīta';
        update book;

        Test.startTest();
        List<BookInUserCollection__c> books = BookInUserCollectionController.getCurrentlyReadingBooks();
        Test.stopTest();

        System.assertEquals(0, books.size(), 'There should be no books currently being read.');
    }

    @IsTest
    static void testUpdateCurrentPage_Success() {
        BookInUserCollection__c book = setupTestData();

        Test.startTest();
        BookInUserCollectionController.updateCurrentPage(book.Id, 100);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Current_page__c FROM BookInUserCollection__c WHERE Id = :book.Id];
        System.assertEquals(100, updatedBook.Current_page__c, 'Current page should be updated.');
    }

    @IsTest
    static void testUpdateCurrentPage_LessThanOne() {
        BookInUserCollection__c book = setupTestData();
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.updateCurrentPage(book.Id, 0);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for invalid page number.');
    }

    @IsTest
    static void testMarkBookAsCompleted_Success() {
        BookInUserCollection__c book = setupTestData();

        Test.startTest();
        BookInUserCollectionController.markBookAsCompleted(book.Id);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Reading_status__c, Date_finished__c, Times_read__c, Current_page__c 
                                               FROM BookInUserCollection__c 
                                               WHERE Id = :book.Id];
        System.assertEquals('Izlasīta', updatedBook.Reading_status__c, 'Reading status should be updated to "Izlasīta".');
        System.assertEquals(Date.today(), updatedBook.Date_finished__c, 'Date finished should be today.');
        System.assertEquals(2, updatedBook.Times_read__c, 'Times read should increment.');
        System.assertEquals(0, updatedBook.Current_page__c, 'Current page should reset to 0.');
    }

    @IsTest
    static void testMarkBookAsCompleted_InvalidId() {
        Boolean didThrowException = false;
    
        Test.startTest();
        try {
            BookInUserCollectionController.markBookAsCompleted(null); // Invalid ID
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();
    
        System.assert(didThrowException, 'Expected an exception for null ID.');
    }


    @IsTest
    static void testAddToCollection_Success() {
        Genre__c testGenre = new Genre__c(Name = 'New Fiction');
        insert testGenre;

        Book__c testBook = new Book__c(Name = 'New Book', Genre__c = testGenre.Id);
        insert testBook;

        Test.startTest();
        BookInUserCollectionController.addToCollection(testBook.Id, 'Gribu izlasīt', Date.today(), '1234567890');
        Test.stopTest();

        BookInUserCollection__c newEntry = [SELECT Id, Reading_status__c, Date_bought__c, ISBN__c 
                                            FROM BookInUserCollection__c 
                                            WHERE Book__c = :testBook.Id];
        System.assertEquals('Gribu izlasīt', newEntry.Reading_status__c, 'Reading status should match.');
        System.assertEquals(Date.today(), newEntry.Date_bought__c, 'Date bought should be today.');
        System.assertEquals('1234567890', newEntry.ISBN__c, 'ISBN should match.');
    }

    @IsTest
    static void testAddToCollection_InvalidDate() {
        Genre__c testGenre = new Genre__c(Name = 'New Fiction');
        insert testGenre;

        Book__c testBook = new Book__c(Name = 'New Book', Genre__c = testGenre.Id);
        insert testBook;

        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.addToCollection(testBook.Id, 'Gribu izlasīt', Date.today().addDays(1), '1234567890'); // Future date
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for future date.');
    }
    
    @IsTest
    static void testUpdateBookCollection_Success() {
        BookInUserCollection__c book = setupTestData();
        book.Date_finished__c = Date.today();

        Test.startTest();
        BookInUserCollectionController.updateBookCollection(book);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Date_finished__c FROM BookInUserCollection__c WHERE Id = :book.Id];
        System.assertEquals(Date.today(), updatedBook.Date_finished__c, 'Date finished should be updated.');
    }

    @IsTest
    static void testUpdateBookCollection_FutureStartDate() {
        BookInUserCollection__c book = setupTestData();
        book.Date_started__c = Date.today().addDays(1);
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.updateBookCollection(book);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for future start date.');
    }

    @IsTest
    static void testUpdateBookCollection_FutureFinishDate() {
        BookInUserCollection__c book = setupTestData();
        book.Date_finished__c = Date.today().addDays(1);
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.updateBookCollection(book);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for future finish date.');
    }

    @IsTest
    static void testUpdateBookCollection_NullFormat() {
        BookInUserCollection__c book = setupTestData();
        book.Format__c = 'Nav norādīts';

        Test.startTest();
        BookInUserCollectionController.updateBookCollection(book);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Format__c FROM BookInUserCollection__c WHERE Id = :book.Id];
        System.assertEquals(null, updatedBook.Format__c, 'Format should be set to null.');
    }

    @IsTest
    static void testUpdateBookCollection_NullReadingStatus() {
        BookInUserCollection__c book = setupTestData();
        book.Reading_status__c = 'Nav';

        Test.startTest();
        BookInUserCollectionController.updateBookCollection(book);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Reading_status__c FROM BookInUserCollection__c WHERE Id = :book.Id];
        System.assertEquals(null, updatedBook.Reading_status__c, 'Reading status should be set to null.');
    }

    @IsTest
    static void testUpdateBookCollection_BlankReadingStatus() {
        BookInUserCollection__c book = setupTestData();
        book.Reading_status__c = '';

        Test.startTest();
        BookInUserCollectionController.updateBookCollection(book);
        Test.stopTest();

        BookInUserCollection__c updatedBook = [SELECT Reading_status__c FROM BookInUserCollection__c WHERE Id = :book.Id];
        System.assertEquals(null, updatedBook.Reading_status__c, 'Reading status should be set to null when blank.');
    }
    
    @IsTest
    static void testDeleteBookFromCollection_Success() {
        BookInUserCollection__c bookInUserCollection = setupTestData();

        Test.startTest();
        BookInUserCollectionController.deleteBookFromCollection(bookInUserCollection.Id);
        Test.stopTest();

        List<BookInUserCollection__c> deletedBooks = [SELECT Id FROM BookInUserCollection__c WHERE Id = :bookInUserCollection.Id];
        System.assertEquals(0, deletedBooks.size(), 'The book should be deleted from the collection.');
    }

    @IsTest
    static void testDeleteBookFromCollection_MissingRecordId() {
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.deleteBookFromCollection(null);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for missing record ID.');
    }
    
    @IsTest
    static void testGetRecommendedBooks_Success() {
        BookInUserCollection__c book = setupTestData();

        Test.startTest();
        List<Book__c> recommendedBooks = BookInUserCollectionController.getRecommendedBooks(book.Id);
        Test.stopTest();

        System.assertNotEquals(null, recommendedBooks, 'Recommended books should not be null.');
        System.assert(recommendedBooks.size() <= 10, 'Recommended books should not exceed 10.');
    }

    @IsTest
    static void testGetRecommendedBooks_NoGenre() {
        BookInUserCollection__c book = setupTestData();
        Book__c testBook = [SELECT Genre__c FROM Book__c WHERE Id = :book.Book__c];
        testBook.Genre__c = null;
        update testBook;

        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookInUserCollectionController.getRecommendedBooks(book.Id);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for missing genre.');
    }
}
