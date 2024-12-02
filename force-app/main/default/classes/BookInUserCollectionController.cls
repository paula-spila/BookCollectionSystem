public with sharing class BookInUserCollectionController {

    @AuraEnabled(cacheable=true)
    public static List<BookInUserCollection__c> getBooks(String collectionType) {
        Id currentUserId = UserInfo.getUserId();
        System.debug('Current User ID: ' + currentUserId);
        System.debug('Collection Type: ' + collectionType);

        List<BookInUserCollection__c> userBooks = new List<BookInUserCollection__c>();

        if (collectionType == 'allBooks') {
            userBooks = [
                SELECT Id, 
                    Book__r.Name, 
                    Book__r.Author__r.Name,
                    Book__r.Author__r.Surname__C, 
                    Book__r.Genre__r.Name, 
                    Book__r.Book_cover__c, 
                    Reading_status__c
                FROM BookInUserCollection__c
                WHERE User__c = :currentUserId
            ];
        } else if (collectionType == 'readBooks') {
            userBooks = [
                SELECT Id, 
                    Book__r.Name, 
                    Book__r.Author__r.Name,
                    Book__r.Author__r.Surname__C, 
                    Book__r.Genre__r.Name, 
                    Book__r.Book_cover__c, 
                    Reading_status__c
                FROM BookInUserCollection__c
                WHERE User__c = :currentUserId AND Reading_status__c = 'Read'
            ];
        } else if (collectionType == 'wantToRead') {
            userBooks = [
                SELECT Id, 
                    Book__r.Name, 
                    Book__r.Author__r.Name, 
                    Book__r.Author__r.Surname__C,
                    Book__r.Genre__r.Name, 
                    Book__r.Book_cover__c, 
                    Reading_status__c
                FROM BookInUserCollection__c
                WHERE User__c = :currentUserId AND Reading_status__c = 'Want to Read'
            ];
        }

        System.debug('Books Retrieved: ' + userBooks);
        return userBooks;
    }

    @AuraEnabled(cacheable=true)
    public static List<BookInUserCollection__c> getCurrentlyReadingBooks() {
        try {
            return [
                SELECT Id,
                       Current_page__c,
                       Book__r.Name,
                       Book__r.Author__r.Name,
                       Book__r.Author__r.Surname__c,
                       Book__r.Number_of_pages__c
                FROM BookInUserCollection__c
                WHERE Reading_status__c = 'Currently reading'
                  AND OwnerId = :UserInfo.getUserId()
                ORDER BY LastModifiedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching currently reading books: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateCurrentPage(Id bookId, Integer currentPage) {
        try {
            BookInUserCollection__c book = [
                SELECT Id, Current_page__c, Book__r.Number_of_pages__c 
                FROM BookInUserCollection__c 
                WHERE Id = :bookId 
                LIMIT 1
            ];

            if (currentPage < 1) {
                throw new AuraHandledException('Current page cannot be less than 1.');
            }

            if (currentPage > book.Book__r.Number_of_pages__c) {
                throw new AuraHandledException(
                    'Current page cannot exceed the total number of pages in the book (' + book.Book__r.Number_of_pages__c + ').'
                );
            }

            book.Current_page__c = currentPage;
            update book;

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void markBookAsCompleted(Id bookId) {
        BookInUserCollection__c book = [
            SELECT Id, Current_page__c, Times_read__c, Date_finished__c, Reading_status__c
            FROM BookInUserCollection__c
            WHERE Id = :bookId
            LIMIT 1
        ];

        book.Reading_status__c = 'Read';
        book.Date_finished__c = Date.today();
        book.Times_read__c = (book.Times_read__c != null ? book.Times_read__c + 1 : 1);
        book.Current_page__c = 0;

        update book;
    }

}
