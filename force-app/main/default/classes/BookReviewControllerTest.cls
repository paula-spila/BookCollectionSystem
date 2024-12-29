@isTest
public with sharing class BookReviewControllerTest {
    static void setupTestData() {
        Book__c testBook = new Book__c(Name = 'Test Book');
        insert testBook;

        Book_Review__c review = new Book_Review__c(
            Book__c = testBook.Id,
            Rating__c = 5,
            Review_text__c = 'Excellent Book',
            Date_of_review__c = Date.today()
        );
        insert review;
    }

    @isTest
    static void testAddReviewSuccess() {
        setupTestData();
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Test Book' LIMIT 1];

        Test.startTest();
        Id reviewId = BookReviewController.addReview(
            testBook.Id,
            4,
            'This is an example review text.'
        );
        Test.stopTest();

        System.assertNotEquals(null, reviewId, 'Review ID should not be null.');

        Book_Review__c insertedReview = [SELECT Id, Book__c, Rating__c, Review_text__c 
                                         FROM Book_Review__c 
                                         WHERE Id = :reviewId];
        System.assertEquals(testBook.Id, insertedReview.Book__c, 'Book ID should match.');
        System.assertEquals(4, insertedReview.Rating__c, 'Rating should match.');
        System.assertEquals('This is an example review text.', insertedReview.Review_text__c, 'Review text should match.');
    }

    @isTest
    static void testAddReviewMissingBookId() {
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookReviewController.addReview(null, 3, 'Review text');
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception to be thrown for missing Book ID.');
    }

    @isTest
    static void testAddReviewInvalidRating() {
        setupTestData();
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Test Book' LIMIT 1];
        Boolean didThrowException = false;

        Test.startTest();
        try {
            BookReviewController.addReview(testBook.Id, 6, 'Review text'); // Invalid rating above 5
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception to be thrown for invalid rating.');
    }

    @isTest
    static void testAddReviewTooLongReviewText() {
        setupTestData();
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Test Book' LIMIT 1];
        Boolean didThrowException = false;

        String longReviewText = 'a'.repeat(3001); // Exceeds 3000 characters

        Test.startTest();
        try {
            BookReviewController.addReview(testBook.Id, 4, longReviewText);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception to be thrown for review text exceeding maximum length.');
    }

    @isTest
    static void testGetBookReviews() {
        setupTestData();
        Book__c testBook = [SELECT Id FROM Book__c WHERE Name = 'Test Book' LIMIT 1];

        Test.startTest();
        List<Book_Review__c> reviews = BookReviewController.getBookReviews(testBook.Id);
        Test.stopTest();

        System.assertEquals(1, reviews.size(), 'There should be one review.');
        System.assertEquals('Excellent Book', reviews[0].Review_text__c, 'Review text should match.');
    }

    @isTest
    static void testUpdateReviewSuccess() {
        setupTestData();
        Book_Review__c testReview = [SELECT Id FROM Book_Review__c LIMIT 1];

        Test.startTest();
        BookReviewController.updateReview(testReview.Id, 4, 'Updated review text.');
        Test.stopTest();

        Book_Review__c updatedReview = [SELECT Rating__c, Review_text__c FROM Book_Review__c WHERE Id = :testReview.Id];
        System.assertEquals(4, updatedReview.Rating__c, 'Updated rating should match.');
        System.assertEquals('Updated review text.', updatedReview.Review_text__c, 'Updated review text should match.');
    }

    @isTest
    static void testDeleteReviewSuccess() {
        setupTestData();
        Book_Review__c testReview = [SELECT Id FROM Book_Review__c LIMIT 1];

        Test.startTest();
        BookReviewController.deleteReview(testReview.Id);
        Test.stopTest();

        List<Book_Review__c> deletedReviews = [SELECT Id FROM Book_Review__c WHERE Id = :testReview.Id];
        System.assertEquals(0, deletedReviews.size(), 'Review should be deleted.');
    }
}
