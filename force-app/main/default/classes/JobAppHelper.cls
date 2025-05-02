public with sharing class JobAppHelper {
    public void createTask(List<Job_Application__c> jobApps) {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Job_Application__c jobApp : jobApps) {
            Task task = new Task();

            task.Subject = 'Job Application Follow up';
            task.Status = 'Not Started';
            task.Priority = 'Normal';
            task.WhatId = jobApp.Id;
            task.ActivityDate = jobApp.Follow_up_Date__c == null ? jobApp.Follow_up_Date__c : Date.today().addDays(2);
            task.Description = 'Follow up on job application for ' + jobApp.Position__c + ' at ' + jobApp.Company_Name__c;
            tasksToInsert.add(task);
        }
        
        if (!tasksToInsert.isEmpty()) {
            if (Schema.sObjectType.Task.isCreateable()) {
                try {
                    insert tasksToInsert;
                } catch (Exception e) {
                    System.debug('Error creating tasks: ' + e.getMessage()); 
                }
            } else {
                System.debug('User does not have permission to create Task records.');
            }
        }
    }

    public void setDefaultStatus(List<Job_Application__c> jobApps) {
        for (Job_Application__c jobApp : jobApps) {
            if (jobApp.Status__c == null) {
                jobApp.Status__c = 'Saved';
            }
        }
    }

    public void createEvent(List<Job_Application__c> newJobApps) {
        List<Event> eventsToInsert = new List<Event>();
        
        for (Job_Application__c jobApp : newJobApps) { 
            if (jobApp.Interview_Date__c != null) {
                Event event = new Event();
                event.Subject = 'Interview with ' + jobApp.Company_Name__c + ' for ' + jobApp.Position__c;
                event.StartDateTime = jobApp.Interview_Date__c;
                event.EndDateTime = jobApp.Interview_Date__c.addHours(1);
                event.WhatId = jobApp.Id;
                event.OwnerId = jobApp.OwnerId;
                eventsToInsert.add(event);
            }
        }
        
        if (!eventsToInsert.isEmpty()) {
            if (Schema.sObjectType.Event.isCreateable()) {
                try {
                    insert eventsToInsert;
                } catch (Exception e) {
                    System.debug('Error creating events: ' + e.getMessage());
                }
            } else {
                System.debug('User does not have permission to create Event records.');
            }
        }
    }
}