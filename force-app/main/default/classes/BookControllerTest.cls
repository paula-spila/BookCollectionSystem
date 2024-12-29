@IsTest
public with sharing class BookControllerTest {

    private static void setupTestData() {
        Author__c author1 = new Author__c(Name = 'Author One');
        insert author1;
        
        Author__c author2 = new Author__c(Name = 'Author Two');
        insert author2;

        Genre__c genre1 = new Genre__c(Name = 'Science Fiction');
        insert genre1;

        Genre__c genre2 = new Genre__c(Name = 'Fantasy');
        insert genre2;

        Book__c book1 = new Book__c(
            Name = 'Book One',
            Author__c = author1.Id,
            Genre__c = genre1.Id,
            Number_of_pages__c = 300
        );
        insert book1;

        Book__c book2 = new Book__c(
            Name = 'Book Two',
            Author__c = author2.Id,
            Genre__c = genre2.Id,
            Number_of_pages__c = 450
        );
        insert book2;
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

    // Test method for getBookOptions
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

    // Test methods for getBooks
    private static void createTestData() {
        Author__c testAuthor1 = new Author__c(Name='F. Scott Fitzgerald');
        Author__c testAuthor2 = new Author__c(Name='Herman Melville');
        Author__c testAuthor3 = new Author__c(Name='George Orwell');
        insert new List<Author__c>{testAuthor1, testAuthor2, testAuthor3};

        Genre__c testGenre1 = new Genre__c(Name='Novel');
        Genre__c testGenre2 = new Genre__c(Name='Adventure');
        Genre__c testGenre3 = new Genre__c(Name='Dystopian');
        insert new List<Genre__c>{testGenre1, testGenre2, testGenre3};

        List<Book__c> books = new List<Book__c>{
            new Book__c(Name='The Great Gatsby', Author__c=testAuthor1.Id, Genre__c=testGenre1.Id),
            new Book__c(Name='Moby Dick', Author__c=testAuthor2.Id, Genre__c=testGenre2.Id),
            new Book__c(Name='1984', Author__c=testAuthor3.Id, Genre__c=testGenre3.Id)
        };
        insert books;
    }

    @isTest
    static void testGetBooksByTitle() {
        createTestData();
        Test.startTest();
        List<Book__c> results = BookController.getBooks('1984', '', '');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return exactly one book');
        System.assertEquals('1984', results[0].Name, 'The book title should match');
    }

    @isTest
    static void testGetBooksByAuthor() {
        createTestData();
        Test.startTest();
        List<Book__c> results = BookController.getBooks('', 'George Orwell', '');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return exactly one book');
        System.assertEquals('George Orwell', results[0].Author__r.Name, 'The author name should match');
    }

    @isTest
    static void testGetBooksByGenre() {
        createTestData();
        Test.startTest();
        List<Book__c> results = BookController.getBooks('', '', 'Dystopian');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return exactly one book');
        System.assertEquals('Dystopian', results[0].Genre__r.Name, 'The genre should match');
    }

    @isTest
    static void testGetBooksByCombination() {
        createTestData();
        Test.startTest();
        List<Book__c> results = BookController.getBooks('Moby Dick', 'Herman Melville', 'Adventure');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return exactly one book');
        System.assertEquals('Moby Dick', results[0].Name, 'The book title should match');
        System.assertEquals('Herman Melville', results[0].Author__r.Name, 'The author name should match');
        System.assertEquals('Adventure', results[0].Genre__r.Name, 'The genre should match');
    }

    @isTest
    static void testGetBooksNoResults() {
        createTestData();
        Test.startTest();
        List<Book__c> results = BookController.getBooks('Nonexistent Title', '', '');
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return no books');
    }

    // Test methods for addBook
    @isTest
    static void testMissingBookName() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            BookController.addBook(null, Date.today(), 123, 'Valid description', 'a0X1i000000CAXX', 'a0X1i000000CBXX', 'http://example.com/cover.jpg');
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
            BookController.addBook('Test Book', Date.today().addDays(1), 123, 'Valid description', 'a0X1i000000CAXX', 'a0X1i000000CBXX', 'http://example.com/cover.jpg');
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
            BookController.addBook('Test Book', Date.today(), -1, 'Valid description', 'a0X1i000000CAXX', 'a0X1i000000CBXX', 'http://example.com/cover.jpg');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an invalid number of pages.');
    }

    @isTest
    static void testExcessiveDescriptionLength() {
        Boolean exceptionThrown = false;
        String longDescription = String.join(new List<String>(3001), 'a');
        Test.startTest();
        try {
            BookController.addBook('Test Book', Date.today(), 123, longDescription, 'a0X1i000000CAXX', 'a0X1i000000CBXX', 'http://example.com/cover.jpg');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for an excessive description length.');
    }


    @isTest
    static void testSuccessfulBookCreation() {
        setupTestData(); // Assuming this sets up necessary Author__c and Genre__c data.
        Author__c author = [SELECT Id FROM Author__c WHERE Name = 'Author One' LIMIT 1];
        Genre__c genre = [SELECT Id FROM Genre__c WHERE Name = 'Science Fiction' LIMIT 1];

        Test.startTest();
        Id bookId = BookController.addBook('Test Book', Date.today(), 123, 'Valid description', author.Id, genre.Id, 'http://example.com/cover.jpg');
        Test.stopTest();

        Book__c createdBook = [SELECT Id, Name, Book_Cover__c FROM Book__c WHERE Id = :bookId];
        System.assertNotEquals(null, createdBook, 'Book should have been created.');
        System.assertEquals('Test Book', createdBook.Name, 'Book name should match.');
        System.assertEquals('http://example.com/cover.jpg', createdBook.Book_Cover__c, 'Book cover URL should match.');
    }
    
    @isTest
    static void testGetBookDetails() {
        setupTestData();
    
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Book One' LIMIT 1];
    
        Test.startTest();
        Book__c fetchedBook = BookController.getBookDetails(testBook.Id);
        Test.stopTest();
    
        System.assertNotEquals(null, fetchedBook, 'Fetched book should not be null.');
        System.assertEquals(testBook.Id, fetchedBook.Id, 'Fetched book ID should match the inserted book ID.');
        System.assertEquals('Book One', fetchedBook.Name, 'Book name should match.');
        System.assertEquals(300, fetchedBook.Number_of_pages__c, 'Number of pages should match.');
        System.assertEquals('Author One', fetchedBook.Author__r.Name, 'Author name should match.');
        System.assertEquals('Science Fiction', fetchedBook.Genre__r.Name, 'Genre name should match.');
    }
    
    @isTest
    static void testGetBookDetails_Exception() {
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.getBookDetails(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
	
    @isTest
    static void testGetBooksByAuthor_Success() {
        setupTestData();
    
        Author__c testAuthor = [SELECT Id FROM Author__c WHERE Name = 'Author One' LIMIT 1];
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Book One' LIMIT 1];
    
        Test.startTest();
        List<Book__c> booksByAuthor = BookController.getBooksByAuthor(testAuthor.Id, testBook.Id);
        Test.stopTest();
    
        System.assert(booksByAuthor != null, 'The result should not be null.');
        System.assertEquals(0, booksByAuthor.size(), 'There should be no other books for this author excluding the current book.');
    }
    
    @isTest
    static void testGetBooksByAuthor_NoAuthorId() {
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.getBooksByAuthor(null, null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
    
    @isTest
    static void testGetBooksByAuthor_NoResults() {
        setupTestData();
    
        Author__c testAuthor = [SELECT Id FROM Author__c WHERE Name = 'Author Two' LIMIT 1];
    
        Test.startTest();
        List<Book__c> booksByAuthor = BookController.getBooksByAuthor(testAuthor.Id, null);
        Test.stopTest();
    
        System.assert(booksByAuthor != null, 'The result should not be null.');
    }
    @isTest
    static void testUpdateBook_Success() {
        setupTestData();
    
        Book__c bookToUpdate = [
            SELECT Id, Name, Number_of_pages__c, Publication_date__c, Description__c, Book_cover__c
            FROM Book__c
            WHERE Name = 'Book One'
            LIMIT 1
        ];
        bookToUpdate.Name = 'Updated Book Name';
        bookToUpdate.Number_of_pages__c = 350;
    
        Test.startTest();
        BookController.updateBook(bookToUpdate);
        Test.stopTest();
    
        Book__c updatedBook = [
            SELECT Id, Name, Number_of_pages__c
            FROM Book__c
            WHERE Id = :bookToUpdate.Id
        ];
        System.assertEquals('Updated Book Name', updatedBook.Name, 'The book name should be updated.');
        System.assertEquals(350, updatedBook.Number_of_pages__c, 'The number of pages should be updated.');
    }
    
    @isTest
    static void testUpdateBook_NullBook() {
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.updateBook(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
    
    @isTest
    static void testUpdateBook_MissingName() {
        setupTestData();
    
        Book__c bookToUpdate = [
            SELECT Id, Name, Number_of_pages__c, Description__c, Book_cover__c
            FROM Book__c
            WHERE Name = 'Book One'
            LIMIT 1
        ];
        bookToUpdate.Name = null;
    
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.updateBook(bookToUpdate);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
    
    @isTest
    static void testUpdateBook_NegativePages() {
        setupTestData();
    
        Book__c bookToUpdate = [
            SELECT Id, Name, Number_of_pages__c
            FROM Book__c
            WHERE Name = 'Book One'
            LIMIT 1
        ];
        bookToUpdate.Number_of_pages__c = -50;
    
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.updateBook(bookToUpdate);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
    
    @isTest
    static void testUpdateBook_FuturePublicationDate() {
        setupTestData();
    
        Book__c bookToUpdate = [
            SELECT Id, Name, Publication_date__c, Number_of_pages__c
            FROM Book__c
            WHERE Name = 'Book One'
            LIMIT 1
        ];
        bookToUpdate.Publication_date__c = Date.today().addDays(10);
    
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.updateBook(bookToUpdate);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }
    
    @isTest
    static void testUpdateBook_DescriptionTooLong() {
        setupTestData();
    
        Book__c bookToUpdate = [
            SELECT Id, Name, Description__c, Number_of_pages__c, Publication_date__c, Book_cover__c
            FROM Book__c
            WHERE Name = 'Book One'
            LIMIT 1
        ];
        bookToUpdate.Description__c = String.join(new List<String>(5001), 'a');
    
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
    
        Test.startTest();
        try {
            BookController.updateBook(bookToUpdate);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
    
        System.assert(exceptionThrown, 'Expected AuraHandledException was not thrown.');
    }

}
