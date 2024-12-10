@isTest
public with sharing class BookReviewControllerTest {
    // @isTest
    // static void testAddReviewSuccess() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     Test.startTest();
    //     Id reviewId = BookReviewController.addReview(
    //         testBook.Id,
    //         'Great Review',
    //         Date.today(),
    //         4,
    //         'This is an example review text.'
    //     );
    //     Test.stopTest();

    //     System.assertNotEquals(null, reviewId, 'Review ID should not be null.');

    //     Book_Review__c insertedReview = [SELECT Id, Name, Book__c, Date_of_review__c, Rating__c, Review_text__c 
    //                                      FROM Book_Review__c 
    //                                      WHERE Id = :reviewId];
    //     System.assertEquals('Great Review', insertedReview.Name, 'Review Name should match.');
    //     System.assertEquals(testBook.Id, insertedReview.Book__c, 'Book ID should match.');
    //     System.assertEquals(4, insertedReview.Rating__c, 'Rating should match.');
    //     System.assertEquals('This is an example review text.', insertedReview.Review_text__c, 'Review text should match.');
    // }

    // @isTest
    // static void testAddReviewMissingBookId() {
    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             null,
    //             'Review without Book',
    //             Date.today(),
    //             3,
    //             'Review text'
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for missing Book ID.');
    // }

    // @isTest
    // static void testAddReviewMissingReviewName() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             testBook.Id,
    //             '',
    //             Date.today(),
    //             3,
    //             'Review text'
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for missing Review Name.');
    // }

    // @isTest
    // static void testAddReviewInvalidReviewNameLength() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             testBook.Id,
    //             'This is a very long review name that exceeds the maximum allowed length of 80 characters for testing purposes.',
    //             Date.today(),
    //             3,
    //             'Review text'
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for review name exceeding maximum length.');
    // }

    // @isTest
    // static void testAddReviewInvalidReviewTextLength() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     String longText = String.join(new List<String>(3006), 'a');

    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             testBook.Id,
    //             'Valid Review Name',
    //             Date.today(),
    //             3,
    //             longText
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for review text exceeding maximum length.');
    // }

    // @isTest
    // static void testAddReviewInvalidRating() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             testBook.Id,
    //             'Valid Review Name',
    //             Date.today(),
    //             6, // Invalid rating above 5
    //             'Review text'
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for invalid rating.');
    // }

    // @isTest
    // static void testAddReviewFutureDate() {
    //     Book__c testBook = new Book__c(Name = 'Test Book');
    //     insert testBook;

    //     Boolean didThrowException = false;

    //     try {
    //         Test.startTest();
    //         BookReviewController.addReview(
    //             testBook.Id,
    //             'Valid Review Name',
    //             Date.today().addDays(1),
    //             3,
    //             'Review text'
    //         );
    //         Test.stopTest();
    //     } catch (Exception e) {
    //         didThrowException = true;
    //     }

    //     System.assert(didThrowException, 'Expected an exception to be thrown for date of review in the future.');
    // }
}
