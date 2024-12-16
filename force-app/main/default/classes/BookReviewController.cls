public with sharing class BookReviewController {
    @AuraEnabled
    public static Id addReview(Id bookId, Integer rating, String reviewText) {
        if (bookId == null) {
            throw new AuraHandledException('Missing required field: Book.');
        }

        if (reviewText != null && reviewText.length() > 3000) {
            throw new AuraHandledException('Review Text should not exceed 3000 characters.');
        }
        if (rating != null && (rating < 0 || rating > 5)) {
            throw new AuraHandledException('Rating should be between 0 and 5.');
        }

        Book_Review__c newReview = new Book_Review__c(
            Book__c = bookId,
            Date_of_review__c = Date.today(),
            Rating__c = rating,
            Review_text__c = reviewText
        );

        try {
            insert newReview;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('Error creating new review: ' + e.getMessage());
        }

        return newReview.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Book_Review__c> getBookReviews(Id bookId) {
        try {
            return [
                SELECT Id, CreatedBy.Name, Review_text__c, Rating__c
                FROM Book_Review__c
                WHERE Book__c = :bookId
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching book reviews: ' + ex.getMessage());
        }
    }
}
