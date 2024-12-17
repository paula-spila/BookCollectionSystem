public with sharing class WishlistController {

    @AuraEnabled
    public static Boolean isBookInWishlist(Id bookId) {
        if (bookId == null) {
            throw new AuraHandledException('Book ID is required.');
        }

        Integer count = [
            SELECT COUNT()
            FROM Wishlist__c
            WHERE Book__c = :bookId AND OwnerId = :UserInfo.getUserId()
        ];

        return count > 0;
    }

    @AuraEnabled
    public static void addToWishlist(Id bookId) {
        if (bookId == null) {
            throw new AuraHandledException('Book ID is required to add to the wishlist.');
        }

        if (isBookInWishlist(bookId)) {
            throw new AuraHandledException('The book is already in the wishlist.');
        }

        Wishlist__c newWishlistEntry = new Wishlist__c(
            Book__c = bookId,
            Date_added__c = Date.today()
        );

        try {
            insert newWishlistEntry;
        } catch (Exception e) {
            throw new AuraHandledException('Error adding book to wishlist: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFromWishlist(Id bookId) {
        if (bookId == null) {
            throw new AuraHandledException('Book ID is required to remove from the wishlist.');
        }

        List<Wishlist__c> wishlistEntries = [
            SELECT Id 
            FROM Wishlist__c 
            WHERE Book__c = :bookId 
            LIMIT 1
        ];

        if (wishlistEntries.isEmpty()) {
            throw new AuraHandledException('The book is not in the wishlist.');
        }

        try {
            delete wishlistEntries;
        } catch (Exception e) {
            throw new AuraHandledException('Error removing book from wishlist: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Wishlist__c> getWishlistBooks(Id userId) {
        return [
            SELECT Id, Book__c, Book__r.Name,Book__r.Book_cover__c, Book__r.Author__r.Name, 
                Book__r.Author__r.Surname__c, Book__r.Genre__r.Name, 
                Date_added__c
            FROM Wishlist__c
            WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY Date_added__c DESC
        ];
    }

}
