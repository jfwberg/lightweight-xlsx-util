String documentId = '015Ae0000093iIJIAY';

Map<String, Compression.ZipEntry> entries = new Compression.ZipReader(
    [SELECT body FROM Document WHERE Id = :documentId LIMIT 1]?.Body
).getEntriesMap();

Map<String, List<List<Object>>> result = xlsx.Parse.toSheetMap(entries);

System.debug(JSON.serializePretty(result.get('12 Days of Christmas')[0]));