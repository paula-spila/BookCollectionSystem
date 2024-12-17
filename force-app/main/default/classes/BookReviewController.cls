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

    @AuraEnabled
    public static List<Book_Review__c> getUserReviews(Id bookId) {
        Id currentUserId = UserInfo.getUserId();
        return [
            SELECT Id, Rating__c, Review_text__c
            FROM Book_Review__c
            WHERE Book__c = :bookId AND CreatedById = :currentUserId
        ];
    }

    @AuraEnabled
    public static void updateReview(Id reviewId, Decimal rating, String reviewText) {
        if (reviewId == null || rating == null || reviewText == null) {
            throw new AuraHandledException('Trūkst obligātie lauki atsauksmei.');
        }
        Book_Review__c review = [SELECT Id, Rating__c, Review_text__c FROM Book_Review__c WHERE Id = :reviewId LIMIT 1];
        review.Rating__c = rating;
        review.Review_text__c = reviewText;
        update review;
    }


    @AuraEnabled
    public static void deleteReview(Id reviewId) {
        Book_Review__c review = [SELECT Id FROM Book_Review__c WHERE Id = :reviewId LIMIT 1];
        delete review;
    }
}
