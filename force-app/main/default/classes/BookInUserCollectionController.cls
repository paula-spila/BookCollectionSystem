public with sharing class BookInUserCollectionController {
    @AuraEnabled(cacheable=true)
    public static List<BookInUserCollection__c> getCurrentlyReadingBooks(Id userId) {
        return [
            SELECT Id, Name, Book__r.Name, Book__r.Author__r.Name, Current_page__c, Book__r.Book_cover__c
            FROM BookInUserCollection__c
            WHERE OwnerId = :userId AND Reading_status__c = 'Currently Reading'
        ];
    }

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
}
