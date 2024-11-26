public with sharing class BookInUserCollectionController {
    @AuraEnabled(cacheable=true)
    public static List<BookInUserCollection__c> getCurrentlyReadingBooks(Id userId) {
        return [
            SELECT Id, Name, Book__r.Name, Book__r.Author__r.Name, Current_page__c, Book__r.Book_cover__c
            FROM BookInUserCollection__c
            WHERE OwnerId = :userId AND Reading_status__c = 'Currently Reading'
        ];
    }


    // @AuraEnabled
    // public static List<BookInUserCollection__c> getAllBooksInUserCollection() {
    //     try {
    //         return [SELECT Id, Book__r.Id, Book__r.Name, Book__r.Author__r.Name, Book__r.Publication_date__c, Book__r.Genre__r.Name
    //                 FROM BookInUserCollection__c
    //                 WHERE User__c = :UserInfo.getUserId()];
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static String lendBook(Id bookId) {
    //     try {
    //         Lending_History__c lending = new Lending_History__c(
    //             BookInUserCollection__c = bookId,
    //             //LentBy__c = UserInfo.getUserId(),
    //             Lending_date__c = Date.today()
    //         );
    //         insert lending;
    //         return 'Book lent successfully';
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static List<BookInUserCollection__c> getUserBookCollection() {
    //     try {
    //         return [SELECT Id, Book__r.Name, User__r.Name, Reading_status__c
    //                 FROM BookInUserCollection__c
    //                 WHERE User__c = :UserInfo.getUserId()];
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static String addBookToCollection(Id bookId) {
    //     try {
    //         BookInUserCollection__c userBook = new BookInUserCollection__c(
    //             Book__c = bookId,
    //             User__c = UserInfo.getUserId(),
    //             Reading_status__c = 'Want to read'
    //         );
    //         insert userBook;
    //         return 'Book added to collection successfully';
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // @AuraEnabled
    // public static String addBookReview(Id bookId, String reviewName, String reviewText, Decimal rating, Date dateOfReview) {
    //     try {
    //         Book_Review__c review = new Book_Review__c(
    //             Book__c = bookId,
    //             Name = reviewName,
    //             Review_text__c = reviewText,
    //             Rating__c = rating,
    //             Date_of_review__c = dateOfReview
    //         );
    //         insert review;
    //         return 'Review added successfully';
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

}
