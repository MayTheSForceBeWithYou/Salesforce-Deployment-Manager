public with sharing class GeneratePackageAura {
    
    @AuraEnabled
    public static void attachXmlToDeployment(Id deploymentId) {
        // Even though this is a void method, the Aura response state
        // should still show ERROR if something goes wrong
        
        // TODO: Should we type check for a deployment object ID?
        List<DeploymentMetadataItem__c> deplMetaItems = [
            SELECT Id, Name
            FROM DeploymentMetadataItem__c
            WHERE Deployment__c = :deploymentId
        ];
        
        
    }
    
    public static Blob packageXmlBlobFromMetadataItems(List<DeploymentMetadataItem__c> dmis) {
        // Build envelope
        XmlStreamWriter xsw = new XmlStreamWriter();
        xsw.writeStartDocument('prefix', 'localname', 'namespaceUri');
        xsw.writeEndDocument();
        System.debug(xsw.getXmlString());
    }
}