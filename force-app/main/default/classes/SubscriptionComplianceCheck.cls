global class SubscriptionComplianceCheck implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
    private static final String METHOD_NAME = SubscriptionComplianceCheck.class.getName();
    
    String query =  'SELECT Id, CompanyAddressCity__c, OrderNumber__c, CompanyAddressCountry__c, CompanyPhone__c, ContactGender__c, ContactLastName__c, '+
                    'ContactFirstName__c, Companyindustry__c, CompanyName__c, PrintVolume__c, BroadcastSoftware__c, PromoterDescription__c, SBQQ__RequiredById__c, ' +
                    'FlowType__c, BroadcastPartner__c, PostalCode__c, Souscription_Conforme__c, ComplianceProcess__c, Status__c, AccessStoreState__c, ' + 
                    'ContractEmail__c, CompanySegment__c, CompanySiret__c ' +
                    'ContactFirstName__c, Companyindustry__c, CompanyName__c, PrintVolume__c, BroadcastSoftware__c, PromoterDescription__c, SBQQ__RequiredById__c, '+
                    'FROM SBQQ__Subscription__c' + '\' '+
				    'WHERE Status__c =: ELEMENTS_MANQUANTS '+ 
				    'AND Souscription_Conforme__c != TRUE '+
                    'AND ComplianceProcess__c =: IMMO_NEUF ';
    
    global List<SBQQ__Subscription__c> start(Database.BatchableContext BC) { 
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<SBQQ__Subscription__c> subToUpdate;
            if(scope !=  null && !scope.isEmpty()){
                subToUpdate = new List<SBQQ__Subscription__c>();
                for(SBQQ__Subscription__c sub : scope) {
                    SBQQ__Subscription__c subToUpdate = setConformiteImmoNeuf(sub);
                    if(subUpdated != null){
                        subToUpdate.add(subToUpdate);
                    }                                 
                }
                if(!subToUpdate.isEmpty()){
                    update subToUpdate;
                    Set<ID> idParentSupsToUpdate = new Set<ID>();
                    for(SBQQ__Subscription__c subUpdated : subToUpdate){
                        if (sub.SBQQ__RequiredById__c != null) {
                            idParentSupsToUpdate.add(sub.SBQQ__RequiredById__c);
                        }
                    }
                    if(!idSupParentsToUpdate.isEmpty()){
                        setParentConforme(idParentSupsToUpdate);
                    }
                }
                
            }
        } catch(Exception e) {
            Database.rollback(sp);
            Logs.error(METHOD_NAME,'Batch Compliance Check', e);
        }
    }
    
    global void finish(Database.BatchableContext cnx) {
    }
    

    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
        if(sub == null) return null;

        if(sub.PromoterDescription__c != null 
                && sub.FlowType__c != null 
                && sub.ProductWorkflow__c != null
          && sub.ContractEmail__c != null 
          && sub.CompanySiret__c != null 
          && sub.CompanyName__c != null
          && sub.CompanyAddressStreet__c != null 
          && sub.CompanyAddressZipcode__c != null 
          && sub.CompanyAddressCity__c != null
          && sub.CompanyPhone__c != null 
          && sub.ContactGender__c != null 
          && sub.ContactFirstName__c != null 
          && sub.ContactLastName__c != null 
          && sub.LeadPhone__c != null) {
            sub.Souscription_Conforme__c = true;           
        }
         return sub;
    }
    
    private void setParentConforme(List<ID> parentIds) {
        SBQQ__Subscription__c[] parentSubs = [SELECT Id, Souscription_Conforme__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id = :parentIds];
        if (parentSubs.size() > 0) {
            for(SBQQ__Subscription__c parentSub : parentSubs){
                parentSub.Souscription_Conforme__c = true;   
            }             
            UPDATE parentSubs;        
        }
    }
}