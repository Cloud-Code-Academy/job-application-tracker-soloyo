public with sharing class DashboardController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getApplicationStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        Integer totalCount, 
                appliedCount, 
                interviewCount, 
                offerCount;
        
        if (Schema.sObjectType.Job_Application__c.isAccessible()) {
            totalCount = [select COUNT() from Job_Application__c]; // get total count
            appliedCount = [select COUNT() from Job_Application__c where Status__c = 'Applied']; // get total applied count
            interviewCount = [select COUNT() from Job_Application__c where Status__c = 'Interviewing']; // get count of interviews
            offerCount = [select COUNT() from Job_Application__c where Status__c = 'Negotiating' or Status__c = 'Accepted']; // get the count of offers
        }

        stats.put('Total', totalCount);        
        stats.put('Applied', appliedCount);
        stats.put('Interviews', interviewCount);
        stats.put('Offers', offerCount);        
        
        return stats;
    }

    @AuraEnabled(cacheable=true)
    public static List<Event> getUpcomingInterviews() {
        List<Event> events = new List<Event>();
        DateTime today = System.now();
        DateTime nextWeek = today.addDays(7);
        
        if (Schema.sObjectType.Event.isAccessible()) {
            events = [select Id, Subject, StartDateTime, EndDateTime, WhoId 
                        from Event 
                        where StartDateTime >= :today and StartDateTime <= :nextWeek and Subject like '%Interview%'];
        }
        
        return events;
    }

    @AuraEnabled(cacheable=true)
    public static List<Task> getPendingTasks() {
        List<Task> tasks = new List<Task>();
        DateTime today = System.now();
        
        if (Schema.sObjectType.Task.isAccessible()) {
            tasks = [select Id, Subject, ActivityDate, Status, Priority, WhatId, WhoId 
                        from Task 
                        where Status != 'Completed'
                        order by ActivityDate asc, Priority asc];
        }
        
        return tasks;
    }

    @AuraEnabled
    public static void completedTask(Id taskId) {
        Task task = new Task(
            Id = taskId,
            Status = 'Completed'
        );

        if (Schema.sObjectType.Task.isUpdateable()) {
            update task;
        } else {
            throw new AuraHandledException('You do not have permission to update tasks.');
        }
    }
}