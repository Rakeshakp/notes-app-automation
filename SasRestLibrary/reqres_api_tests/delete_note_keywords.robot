*** Settings ***
Library    RESTLibrary
Library    JSONLibrary
Library    Collections
Library    String
Library    OperatingSystem
Resource    ../../resources/variables/common_variables.robot

*** Keywords ***
Read Note ID From Metadata
    ${note_meta}=    Get File    ${NOTE_META_FILE}
    ${note_parts}=   Split String    ${note_meta}    |
    ${note_id}=      Strip String    ${note_parts[0]}
    RETURN           ${note_id}


Delete Note By ID
    [Arguments]    ${delete_url}    ${token}    ${note_id}
    ${token}=      Strip String    ${token}
    ${headers}=    Create Dictionary
    ...            Accept=application/json
    ...            x-auth-token=${token}
    Log            Attempting to delete note with ID: ${note_id}

    Make HTTP Request
    ...    requestId=delete_note_request
    ...    url=${delete_url}
    ...    method=DELETE
    ...    requestHeaders=${headers}
    ...    expectedStatusCode=200
    ...    responseVerificationType=none

    ${deleted_id}=    Execute RC    <<<rc, delete_note_request, body, $.data.id>>
    Log To Console     Deleted note ID from response: ${deleted_id}

    #Clear Metadata File

#Clear Metadata File
#    Create File    ${NOTE_META_FILE}
#    Log            Metadata file cleared
