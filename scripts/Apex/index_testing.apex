// As data map list 
Map<Integer,String> worksheetIndexNameMap = xlsx.Parse.toWorksheetIndexNameMap(
    new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Ae00000A5mEMIAZ' LIMIT 1]?.Body
    ).getEntriesMap(),
    new Set<Integer>{2}
);


Map<String,Integer> worksheetNameIndexMap = xlsx.Parse.toWorksheetNameIndexMap(
    new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Ae00000A5mEMIAZ' LIMIT 1]?.Body
    ).getEntriesMap(),
    new Set<Integer>{2}
);

System.debug(worksheetIndexNameMap);
System.debug(worksheetNameIndexMap);