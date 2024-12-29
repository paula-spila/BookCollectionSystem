@IsTest
public class WishlistControllerTest {
    static Book__c setupTestBook() {
        Genre__c testGenre = new Genre__c(Name = 'Fiction');
        insert testGenre;

        Book__c testBook = new Book__c(
            Name = 'Test Book',
            Genre__c = testGenre.Id,
            Number_of_pages__c = 300
        );
        insert testBook;

        return testBook;
    }

    static Wishlist__c setupTestWishlist(Book__c book) {
        Wishlist__c wishlist = new Wishlist__c(
            Book__c = book.Id,
            Date_added__c = Date.today()
        );
        insert wishlist;

        return wishlist;
    }

    @IsTest
    static void testIsBookInWishlist_True() {
        Book__c testBook = setupTestBook();
        setupTestWishlist(testBook);

        Test.startTest();
        Boolean result = WishlistController.isBookInWishlist(testBook.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'Book should be in the wishlist.');
    }

    @IsTest
    static void testIsBookInWishlist_False() {
        Book__c testBook = setupTestBook();

        Test.startTest();
        Boolean result = WishlistController.isBookInWishlist(testBook.Id);
        Test.stopTest();

        System.assertEquals(false, result, 'Book should not be in the wishlist.');
    }

    @IsTest
    static void testIsBookInWishlist_NullBookId() {
        Boolean didThrowException = false;

        Test.startTest();
        try {
            WishlistController.isBookInWishlist(null);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for null Book ID.');
    }

    @IsTest
    static void testAddToWishlist_Success() {
        Book__c testBook = setupTestBook();

        Test.startTest();
        WishlistController.addToWishlist(testBook.Id);
        Test.stopTest();

        Wishlist__c wishlistEntry = [SELECT Id, Book__c FROM Wishlist__c WHERE Book__c = :testBook.Id];
        System.assertNotEquals(null, wishlistEntry, 'Wishlist entry should be created.');
    }

    @IsTest
    static void testAddToWishlist_AlreadyInWishlist() {
        Book__c testBook = setupTestBook();
        setupTestWishlist(testBook);

        Boolean didThrowException = false;

        Test.startTest();
        try {
            WishlistController.addToWishlist(testBook.Id);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for book already in wishlist.');
    }

    @IsTest
    static void testAddToWishlist_NullBookId() {
        Boolean didThrowException = false;

        Test.startTest();
        try {
            WishlistController.addToWishlist(null);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for null Book ID.');
    }

    @IsTest
    static void testRemoveFromWishlist_Success() {
        Book__c testBook = setupTestBook();
        setupTestWishlist(testBook);

        Test.startTest();
        WishlistController.removeFromWishlist(testBook.Id);
        Test.stopTest();

        List<Wishlist__c> wishlistEntries = [SELECT Id FROM Wishlist__c WHERE Book__c = :testBook.Id];
        System.assertEquals(0, wishlistEntries.size(), 'Wishlist entry should be deleted.');
    }

    @IsTest
    static void testRemoveFromWishlist_NotInWishlist() {
        Book__c testBook = setupTestBook();

        Boolean didThrowException = false;

        Test.startTest();
        try {
            WishlistController.removeFromWishlist(testBook.Id);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for book not in wishlist.');
    }

    @IsTest
    static void testRemoveFromWishlist_NullBookId() {
        Boolean didThrowException = false;

        Test.startTest();
        try {
            WishlistController.removeFromWishlist(null);
        } catch (AuraHandledException ex) {
            didThrowException = true;
        }
        Test.stopTest();

        System.assert(didThrowException, 'Expected an exception for null Book ID.');
    }

    @IsTest
    static void testGetWishlistBooks_Success() {
        Book__c testBook = setupTestBook();
        setupTestWishlist(testBook);

        Test.startTest();
        List<Wishlist__c> wishlistBooks = WishlistController.getWishlistBooks(UserInfo.getUserId());
        Test.stopTest();

        System.assertNotEquals(null, wishlistBooks, 'Wishlist books should not be null.');
        System.assertEquals(1, wishlistBooks.size(), 'There should be one book in the wishlist.');
        System.assertEquals(testBook.Id, wishlistBooks[0].Book__c, 'Book ID should match.');
    }

    @IsTest
    static void testGetWishlistBooks_EmptyWishlist() {
        Test.startTest();
        List<Wishlist__c> wishlistBooks = WishlistController.getWishlistBooks(UserInfo.getUserId());
        Test.stopTest();

        System.assertEquals(0, wishlistBooks.size(), 'Wishlist should be empty.');
    }
}
