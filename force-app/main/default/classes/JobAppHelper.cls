/*
JobAppHelper Overview

The 'JobAppHelper' class is designed to provide helper methods that assist in performing specific operations on Job_Application__c records. 
This class is intended to modularize the logic used in the 'JobAppTrigger' to ensure separation of concerns, improve readability, and ease maintenance. 

Methods:
- 'createTask()': 
    - Purpose: Create a follow-up task after a job has been added.

- 'createEvent()': 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's 
      signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and 
      implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class JobAppHelper {
    public void createTask(List<Job_Application__c> jobApps) {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Job_Application__c jobApp : jobApps) {
            Task task = new Task();
            task.Subject = 'Job Application Follow up';
            task.Status = 'Not Started';
            task.Priority = 'Normal';
            task.WhatId = jobApp.Id;
            tasksToInsert.add(task);
        }
        
        if (!tasksToInsert.isEmpty()) {
            if (Schema.sObjectType.Task.isCreateable()) {
                insert tasksToInsert;
            } else {
                // Handle insufficient permissions, e.g., log an error or throw an exception
                System.debug('User does not have permission to create Task records.');
            }
        }
    }

    /*
    public void createEvent(List<Job_Application__c> jobApps) {
        List<Event> eventsToInsert = new List<Event>();
        
        for (Job_Application__c jobApp : jobApps) {
            Event event = new Event();
            event.Subject = 'Job Application Follow up';
            event.StartDateTime = System.now().addDays(7);
            event.EndDateTime = System.now().addDays(7).addHours(1);
            event.WhatId = jobApp.Id;
            eventsToInsert.add(event);
        }
        
        if (!eventsToInsert.isEmpty()) {
            insert eventsToInsert;
        }
    }
    */
}