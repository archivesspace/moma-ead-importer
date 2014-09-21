MOMA EAD Importer
==============================

Custom ArchivesSpace EAD Importer for MOMA EADs

## Basic Info

This is an ArchivesSpace plugin and can be installed following the directions [here.](https://github.com/archivesspace/archivesspace/tree/master/plugins)

The plugin adds a new importer to the application with the id "moma\_ead\_xml". This is a subclass of the standard EAD importer that ships with ArchivesSpace 1.0.9.

The custom importer does the following:

1. Assign a level of 'file' to any component missing a level attribute.

2. Use the 'eadid' tag to populate the id_0 field.

3. Strip out 'unitdate' tags appearing in 'unittitle' tags when setting the resource or component title.

4. Strip out 'lb' tags when creating extent records from 'physdesc' tags. Simplify the logic for parsing 'physdesc' as notes from 'physdesc' tags are not required.

5. Set 'indicator_1' attribute of 'container' records to 'BLANK' when not present to ensure that records are valid.

6. Default 'extent\_type' to 'linear\_feet' when missing so that records import.

7. Default compontent titles 'Untitled' when missing so that records import.

8. Ignore empty 'corpname' tags.

9. Ignore notes that have empty content so that records import.

10. Set date labels when present in source XML rather than using 'creation'.

Theses customizations are specific to version 1.0.9 of ArchivesSpace and may not work with later versions.

## Pre-processing Script

This package also contains a stand-alone script for replacing HTML character entities with the numeric equivalents that are expected by XML parsers. To run the script:

    ./scripts/replace_entities.rb {directory_containing_eads} {blank_directory}





