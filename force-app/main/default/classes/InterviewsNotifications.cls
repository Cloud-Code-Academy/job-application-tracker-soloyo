public with sharing class InterviewsNotifications {
    public static void upcomingInterviewNotifications() {
        Date tomorrow = Date.today().addDays(1);

        if (Schema.sObjectType.Events.isAccessible()) {
            List<Event> interviews = [
                select Id, Subject, Description, Location, StartDateTime, EndDateTime, 
                    WhatId, What.Name, WhoId, Who.Name, OwnerId, Owner.Name, Owner.Email,
                    IsAllDayEvent, ShowAs
                from Event
                where StartDateTime >= :tomorrowStart
                and StartDateTime <= :tomorrowEnd
                and OwnerId != null
                order by StartDateTime asc
            ];
        }

        Map<Id, List<Event>> interviewsByOwner = new Map<Id, List<Event>>();
        
        // grouped tasks by owners
        for (Event interview : interviews) {
            if (!interviewsByOwner.containsKey(task.OwnerId)) {
                interviewsByOwner.put(interview.OwnerId, new List<Task>());
            }

            interviewsByOwner.get(interview.OwnerId).add(interview);
        }

        for (Id ownerId : interviewsByOwner.keySet()) {
            List<Event> ownerInterviews = interviewsByOwner.get(ownerId);
            
            if (ownerInterviews.isEmpty()) continue;
            
            String ownerEmail = ownerInterviews[0].Owner.Email;
            String ownerName = ownerInterviews[0].Owner.Name;
            
            // create email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ownerEmail};

            mail.setToAddresses(toAddresses);
            mail.setSubject('You have ' + ownerInterviews.size() + ' interview(s) tomorrow');
            
            String body = 'Hello ' + ownerName + ',\n\n';
            body += 'This is a reminder that you have the following interview(s) due tomorrow:\n\n';
            
            for (Task interview : ownerInterviews) {
                body += '• Subject: ' + interview.Subject + '\n';
                
                if (interview.WhatId != null) {
                    body += '  Start: ' + interview.StartDateTime + '\n';
                }
                
                if (interview.Description != null && interview.Description.trim() != '') {
                    body += '  Description: ' + interview.Description + '\n';
                }
            }
            
            body += 'Prepare yourself and good luck!\n\n';
            
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