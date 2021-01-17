@isTest
public with sharing class TEST_DataFactory {

    

    public static Account createAccount(String AccountName, String phone, String siret) {        
    	Account res = new Account(
            Name = AccountName, 
            Phone = phone,
            CompanySiretNumber__c = siret,
        	BillingStreet = '00 SomeWhere',
        	BillingCity = 'SinCity',
        	BillingCountry = 'France',
        	BillingPostalcode = '75000');   
        return res;
    }

    public static Acces_beneficiaire__c createBeneficiaire(String name,
                                                          ID compteId,
                                                          String email,
                                                          String statut) {
        
        Acces_beneficiaire__c result = new Acces_beneficiaire__c(
            Name = name,  
            AccessAccount__c = compteId,
            AccessEmail__c = email, 
            AccessStoreState__c = statut);
        return result;
    }
}