trigger UpdateTutorOnLearningSession on Learning_Session__c (before insert) 
{
    Map<Id, Learning_Session__c> mapSessions = new Map<Id, Learning_Session__c>();
    Set<Id> whoIds = new Set<Id>();
    ID AssessmentRecordTypeID = [select ID from RecordType where Name='Assessment session' limit 1].id;

    for(Learning_Session__c lsNew : Trigger.new)
    {
        if (lsNew.Tutor__c == null)
        {
	        //Add the session to the Map and Set index by the learner id
            mapSessions.put(lsNew.Learner__c, lsNew);
            whoIds.add(lsNew.Learner__c);
        }
    }
    
    List<Learner__c> learners = [select Id, Tutor_for_DL__c, Learning_Support_Worker__c from Learner__c where ID in :whoIDs];
    For(Learner__c learner: learners)
    {
	   	Learning_Session__c ls = mapSessions.get(learner.Id);
	   	if (ls.RecordTypeId == AssessmentRecordTypeID)
	   	{
	   		ls.Tutor__c = learner.Learning_Support_Worker__c;
	   	}
	   	else
	   	{
	   		ls.Tutor__c = learner.Tutor_for_DL__c;
	   	}
    }
}