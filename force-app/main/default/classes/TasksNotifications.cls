public with sharing class TasksNotifications {
    public static void upcomingTasksNotifications() {
        Date tomorrow = Date.today().addDays(1);
        List<Task> tasks = new List<Task>();
        
        if (Schema.sObjectType.Task.isAccessible()) {
            tasks = [
                select Id, Subject, ActivityDate, Description, OwnerId, Owner.Email, Owner.Name, WhatId, What.Name, WhoId, Who.Name 
                from Task 
                where ActivityDate = :tomorrow and Status != 'Completed'
            ];
        }

        Map<Id, List<Task>> tasksByOwner = new Map<Id, List<Task>>();
        
        // grouped tasks by owners
        for (Task task : tasks) {
            if (!tasksByOwner.containsKey(task.OwnerId)) {
                tasksByOwner.put(task.OwnerId, new List<Task>());
            }

            tasksByOwner.get(task.OwnerId).add(task);
        }

        for (Id ownerId : tasksByOwner.keySet()) {
            List<Task> ownerTasks = tasksByOwner.get(ownerId);
            
            if (ownerTasks.isEmpty()) continue;
            
            String ownerEmail = ownerTasks[0].Owner.Email;
            String ownerName = ownerTasks[0].Owner.Name;
            
            // create email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ownerEmail};

            mail.setToAddresses(toAddresses);
            mail.setSubject('You have ' + ownerTasks.size() + ' task(s) due tomorrow');
            
            String body = 'Hello ' + ownerName + ',\n\n';
            body += 'This is a reminder that you have the following task(s) due tomorrow:\n\n';
            
            for (Task task : ownerTasks) {
                body += '• Subject: ' + task.Subject + '\n';
                
                if (task.WhatId != null) {
                    body += '  Related To: ' + task.What.Name + '\n';
                }
                
                if (task.WhoId != null) {
                    body += '  Related Contact: ' + task.Who.Name + '\n';
                }
                
                if (task.Description != null && task.Description.trim() != '') {
                    body += '  Description: ' + task.Description + '\n';
                }
                
                body += '  Due Date: ' + task.ActivityDate.format() + '\n\n';
            }
            
            body += 'Please complete these tasks or update their due dates as needed.\n\n';
            
            mail.setPlainTextBody(body);
            
            // send email
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (Exception e) {
                System.debug('Error sending email to ' + ownerName + ': ' + e.getMessage());
            }
        }
    }

    public static void overdueTasksNotifications() {
        List<Task> tasks = [
            select Id, Subject, ActivityDate, Description, OwnerId, Owner.Email, Owner.Name, WhatId, What.Name, WhoId, Who.Name 
            from Task 
            where ActivityDate < :Date.today() and Status != 'Completed'
        ];

        Map<Id, List<Task>> tasksByOwner = new Map<Id, List<Task>>();
        
        // grouped tasks by owners
        for (Task task : tasks) {
            if (!tasksByOwner.containsKey(task.OwnerId)) {
                tasksByOwner.put(task.OwnerId, new List<Task>());
            }

            tasksByOwner.get(task.OwnerId).add(task);
        }

        for (Id ownerId : tasksByOwner.keySet()) {
            List<Task> ownerTasks = tasksByOwner.get(ownerId);
            
            if (ownerTasks.isEmpty()) continue;
            
            String ownerEmail = ownerTasks[0].Owner.Email;
            String ownerName = ownerTasks[0].Owner.Name;
            Integer daysOverdue;
            
            // create email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ownerEmail};

            mail.setToAddresses(toAddresses);
            mail.setSubject('URGENT: You have ' + ownerTasks.size() + ' overdue task(s)');
            
            String body = 'Hello ' + ownerName + ',\n\n';
            body += 'This is a notification that you have the following overdue task(s):\n\n';
            
            for (Task task : ownerTasks) {
                daysOverdue = Date.today().daysBetween(task.ActivityDate);

                body += '• Subject: ' + task.Subject + '\n';
                
                if (task.WhatId != null) {
                    body += '  Related To: ' + task.What.Name + '\n';
                }
                
                if (task.WhoId != null) {
                    body += '  Related Contact: ' + task.Who.Name + '\n';
                }
                
                if (task.Description != null && task.Description.trim() != '') {
                    body += '  Description: ' + task.Description + '\n';
                }
                
                body += '  Due Date: ' + task.ActivityDate.format() + ' (' + Math.abs(daysOverdue) + ' days overdue)\n\n';
            }
            
            body += 'Please complete these tasks or update their due dates as soon as possible.\n\n';
            
            mail.setPlainTextBody(body);
            
            // send email
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (Exception e) {
                System.debug('Error sending email to ' + ownerName + ': ' + e.getMessage());
            }
        }
    }
}