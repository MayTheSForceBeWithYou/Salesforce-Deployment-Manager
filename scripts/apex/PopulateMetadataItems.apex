// First get picklist values of MetadataItem__c.Type__c

// I *hope* namespaces don't come back to bite us...
List<Schema.PicklistEntry> typePles = Schema.MetadataItem__c.MetadataType__c.getDescribe().getPicklistValues();

// Create list of Metadata Types to query
Set<String> strMetadataTypes = new Set<String>();
for (Schema.PicklistEntry ple : typePles) {
    strMetadataTypes.add(ple.getValue());
}

// Some types will not be supported by SOQL
Set<String> strUnsupportedTypes = new Set<String>();
// (I made this, and I like Hungarian notation... so, ha)

// Make a List of Metadata Items to insert
List<MetadataItem__c> metaItemsToInsert = new List<MetadataItem__c>();

// Cycle through said Metadata Types and query that!
for (String strMetadataType : strMetadataTypes) {
    // Might need optional fields for different types
    // Trying Id and Name for now
    
    String metadataQuery = 'SELECT Id',
           nameField = 'Name';
    
    // Possible remappings
    if (strMetadataType == 'AuraComponentBundle') {
        strMetadataType = 'AuraDefinitionBundle';
        nameField = 'DeveloperName';
    }
    metadataQuery += ',' + nameField + ' FROM ' + strMetadataType;
    
    
    System.debug('metadataQuery: ' + metadataQuery);
    try {
        List<SObject> metadataResults = Database.query(metadataQuery);
        System.debug('Success! Metadata Results: ' + metadataResults);
        for (SObject sObj : metadataResults) {
            String recordName = (String)sObj.get(nameField);
            System.debug(nameField + ': ' + sObj.get(nameField));
            MetadataItem__c metaItem = new MetadataItem__c(
                Name=recordName,
                MetadataType__c=strMetadataType
            );
            System.debug('metaItem: ' + metaItem);
            metaItemsToInsert.add(metaItem);
        }
    } catch (Exception e) {
        String eMsg = e.getMessage();
        if (eMsg.contains('is not supported')) {
            System.debug('Unsupported type: ' + strMetadataType);
            strUnsupportedTypes.add(strMetadataType);
        } else {
            System.debug('Exception! ' + eMsg);
        }
    }
    
    //  For unsupported types, gonna need a lot of work
    //  Only certain standard objects can be moved via Metadata API
    //  FIGURE IT OUT
    
}