public with sharing class DashboardController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getApplicationStats() {
        Map<String, Integer> stats = new Map<String, Integer>();

        try {
            if (Schema.sObjectType.Job_Application__c.isAccessible()) {
                stats.put('total', [select COUNT() from Job_Application__c]); // get total count
                stats.put('applied', [select COUNT() from Job_Application__c where Status__c = 'Applied']); // get total applied count
                stats.put('interviews', [select COUNT() from Job_Application__c where Status__c = 'Interviewing']); // get count of interviews
                stats.put('offers', [select COUNT() from Job_Application__c where Status__c = 'Negotiating' or Status__c = 'Accepted']); // get the count of offers
            }  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }      
        
        return stats;
    }

    @AuraEnabled(cacheable=true)
    public static List<Job_Application__c> getRecentApplications() {
        List<Job_Application__c> applications = new List<Job_Application__c>();

        try {
            if (Schema.sObjectType.Job_Application__c.isAccessible()) {
                applications = [select Id, Company_Name__c, Application_Date__c, Position__c, Salary__c from Job_Application__c where Application_Date__c = LAST_N_DAYS:7 and Status__c <> 'Saved' order by Application_Date__c desc limit 5];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return applications;
    }

    @AuraEnabled(cacheable=true)
    public static List<Event> getUpcomingInterviews() {
        List<Event> events = new List<Event>();
        DateTime today = System.now();
        DateTime nextWeek = today.addDays(7);
        
        try {
            if (Schema.sObjectType.Event.isAccessible()) {
                events = [select Id, Subject, StartDateTime, EndDateTime, WhoId 
                            from Event 
                            where StartDateTime >= :today and StartDateTime <= :nextWeek and Subject like '%Interview%'];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return events;
    }

    @AuraEnabled(cacheable=true)
    public static List<Task> getPendingTasks() {
        List<Task> tasks = new List<Task>();
        DateTime today = System.now();
        
        try {
            if (Schema.sObjectType.Task.isAccessible()) {
                tasks = [select Id, Subject, ActivityDate, Status, Priority, WhatId, WhoId 
                            from Task 
                            where Status != 'Completed'
                            order by ActivityDate asc, Priority asc];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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