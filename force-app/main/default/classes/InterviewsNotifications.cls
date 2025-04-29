public with sharing class InterviewsNotifications {
    public static void upcomingInterviewNotifications() {
        Date tomorrow = Date.today().addDays(1);
        DateTime tomorrowStart = DateTime.newInstance(tomorrow, Time.newInstance(0, 0, 0, 0));
        DateTime tomorrowEnd = DateTime.newInstance(tomorrow, Time.newInstance(23, 59, 59, 0));
        List<Event> interviews = new List<Event>();

        // TODO: return only records of the current user
        if (Schema.sObjectType.Event.isAccessible()) {
            interviews = [
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

        if (interviews.isEmpty()) {
            System.debug('No interviews scheduled for tomorrow.');
            return;
        }

        Map<Id, List<Event>> interviewsByOwner = new Map<Id, List<Event>>();
        
        // grouped tasks by owners
        for (Event interview : interviews) {
            if (!interviewsByOwner.containsKey(interview.OwnerId)) {
                interviewsByOwner.put(interview.OwnerId, new List<Event>());
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
            String[] toAddresses = new String[] { ownerEmail };            
            Integer count = 1;
            String timeInfo;

            mail.setToAddresses(toAddresses);
            mail.setSubject('You have ' + ownerInterviews.size() + ' interview(s) tomorrow');
            
            String body = 'Hello ' + ownerName + ',\n\n';
            body += 'This is a reminder that you have the following interview(s) scheduled for tomorrow:\n\n';
            
            for (Event interview : ownerInterviews) {
                if (interview.IsAllDayEvent) {
                    timeInfo = 'All Day';
                } else {
                    timeInfo = interview.StartDateTime.format('h:mm a') + ' - ' + interview.EndDateTime.format('h:mm a');
                }
                
                body += '• ' + timeInfo + ': ' + interview.Subject;
                
                if (interview.ShowAs != null && interview.ShowAs != 'Busy') {
                    body += ' (' + interview.ShowAs + ')';
                }
            }
            
            body += '\n\n == EVENT DETAILS ==\n';                
            
            for (Event interview : ownerInterviews) {
                body += 'Subject: ' + interview.Subject + '\n';

                if (interview.IsAllDayEvent) {
                    body += 'All Day Event: Yes\n';
                } else {
                    body += 'Start Time: ' + interview.StartDateTime.format('h:mm a') + '\n';
                    body += 'End Time: ' + interview.EndDateTime.format('h:mm a') + '\n';
                }

                if (interview.Location != null && interview.Location.trim() != '') {
                    body += 'Location: ' + interview.Location + '\n';
                }

                if (interview.Description != null && interview.Description.trim() != '') {
                    body += 'Description: ' + interview.Description + '\n';
                }

                String interviewStatus = (interview.ShowAs != null) ? interview.ShowAs : 'Busy';

                body += 'Status: ' + interviewStatus + '\n';

                count++;
            }
            
            body += 'Prepare yourself and good luck!\n\n';
            
            mail.setPlainTextBody(body);
            
            // send email
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('Successfully sent events notification email to: ' + ownerEmail);
            } catch (Exception e) {
                System.debug('Error sending email to ' + ownerName + ': ' + e.getMessage());
            }
        }
    }
}