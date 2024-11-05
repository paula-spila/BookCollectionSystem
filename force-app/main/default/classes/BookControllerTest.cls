@IsTest
public with sharing class BookControllerTest {
    private static void setupTestData() {
        // Create Author records
        Author__c author1 = new Author__c(Name = 'Author One');
        insert author1;
        
        Author__c author2 = new Author__c(Name = 'Author Two');
        insert author2;

        // Create Genre records
        Genre__c genre1 = new Genre__c(Name = 'Science Fiction');
        insert genre1;

        Genre__c genre2 = new Genre__c(Name = 'Fantasy');
        insert genre2;

        Book__c book1 = new Book__c(
            Name = 'Book One',
            Author__c = author1.Id,
            Genre__c = genre1.Id,
            Date_added__c = Date.today(),
            Number_of_pages__c = 300
        );
        insert book1;

        Book__c book2 = new Book__c(
            Name = 'Book Two',
            Author__c = author2.Id,
            Genre__c = genre2.Id,
            Date_added__c = Date.today(),
            Number_of_pages__c = 450
        );
        insert book2;
    }

    // Test method for getBooks
    @IsTest
    static void testGetBooks() {
        setupTestData();

        Test.startTest();

        List<Book__c> books = BookController.getBooks();

        Test.stopTest();

        System.assertNotEquals(0, books.size(), 'Books list should not be empty');
        System.assertEquals(2, books.size(), 'Books list size should be 2');

        Book__c firstBook = books[0];
        System.assertNotEquals(null, firstBook.Id, 'Book ID should not be null');
        System.assertNotEquals(null, firstBook.Name, 'Book Name should not be null');
        System.assertNotEquals(null, firstBook.Author__r.Name, 'Author Name should not be null');
        System.assertNotEquals(null, firstBook.Genre__r.Name, 'Genre Name should not be null');
        System.assertNotEquals(null, firstBook.Date_added__c, 'Date added should not be null');
        System.assertNotEquals(null, firstBook.Number_of_pages__c, 'Number of pages should not be null');
    }
    
     // Test method for getAuthors
    @IsTest
    static void testGetAuthors() {
        setupTestData();

        Test.startTest();
        List<Author__c> authors = BookController.getAuthors();
        Test.stopTest();

        System.assertNotEquals(0, authors.size(), 'Authors list should not be empty');
        System.assertEquals(2, authors.size(), 'Authors list size should be 2');

        Author__c firstAuthor = authors[0];
        System.assertNotEquals(null, firstAuthor.Id, 'Author ID should not be null');
        System.assertNotEquals(null, firstAuthor.Name, 'Author Name should not be null');
    }

    // Test method for getGenres
    @IsTest
    static void testGetGenres() {
        setupTestData();

        Test.startTest();
        List<Genre__c> genres = BookController.getGenres();
        Test.stopTest();

        System.assertNotEquals(0, genres.size(), 'Genres list should not be empty');
        System.assertEquals(2, genres.size(), 'Genres list size should be 2');

        Genre__c firstGenre = genres[0];
        System.assertNotEquals(null, firstGenre.Id, 'Genre ID should not be null');
        System.assertNotEquals(null, firstGenre.Name, 'Genre Name should not be null');
    }
    
    @isTest
    static void testMissingBookName() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            BookController.addBook(null, Date.today(), 123, 'Valid description', Date.today(), 'a0X1i000000CAXX', 'a0X1i000000CBXX', '123-4567890123');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown.');
    }

    @isTest
    static void testPublicationDateInFuture() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            BookController.addBook('Test Book', Date.today().addDays(1), 123, 'Valid description', Date.today(), 'a0X1i000000CAXX', 'a0X1i000000CBXX', '123-4567890123');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for a future publication date.');
    }

    @isTest
    static void testInvalidNumberOfPages() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            BookController.addBook('Test Book', Date.today(), -1, 'Valid description', Date.today(), 'a0X1i000000CAXX', 'a0X1i000000CBXX', '123-4567890123');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an invalid number of pages.');
    }

    @isTest
    static void testAddedDateInFuture() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            BookController.addBook('Test Book', Date.today(), 123, 'Valid description', Date.today().addDays(1), 'a0X1i000000CAXX', 'a0X1i000000CBXX', '123-4567890123');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an added date in the future.');
    }

    @isTest
    static void testExcessiveDescriptionLength() {
        Boolean exceptionThrown = false;
        String longDescription = String.join(new List<String>(3001), 'a');
        Test.startTest();
        try {
            BookController.addBook('Test Book', Date.today(), 123, longDescription, Date.today(), 'a0X1i000000CAXX', 'a0X1i000000CBXX', '123-4567890123');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an excessive description length.');
    }

     @isTest
    static void testSuccessfulBookCreation() {
        setupTestData();
        Author__c author = [SELECT Id FROM Author__c WHERE Name = 'Author One' LIMIT 1];
        Genre__c genre = [SELECT Id FROM Genre__c WHERE Name = 'Science Fiction' LIMIT 1];
        
        Test.startTest();
        Id bookId = BookController.addBook('Test Book', Date.today(), 123, 'Valid description', Date.today(), author.Id, genre.Id, '123-4567890123');
        Test.stopTest();

        Book__c createdBook = [SELECT Id, Name FROM Book__c WHERE Id = :bookId];
        System.assertNotEquals(null, createdBook, 'Book should have been created.');
        System.assertEquals('Test Book', createdBook.Name, 'Book name should match.');
    }
    
    @isTest
    static void testGetBookOptions() {
        List<Book__c> testBooks = new List<Book__c>();
        testBooks.add(new Book__c(Name = 'Test Book A'));
        testBooks.add(new Book__c(Name = 'Test Book B'));
        testBooks.add(new Book__c(Name = 'Test Book C'));
        insert testBooks;

        Test.startTest();
        List<Map<String, String>> options = BookController.getBookOptions();
        Test.stopTest();

        System.assertNotEquals(null, options, 'The result should not be null.');
        System.assertEquals(3, options.size(), 'The number of options should match the number of books.');

        Set<String> expectedLabels = new Set<String>{'Test Book A', 'Test Book B', 'Test Book C'};
        Set<String> returnedLabels = new Set<String>();
        for (Map<String, String> option : options) {
            returnedLabels.add(option.get('label'));
            System.assertNotEquals(null, option.get('value'), 'Each option should have a value.');
        }

        System.assertEquals(expectedLabels, returnedLabels, 'The labels should match the book names.');
    }
}