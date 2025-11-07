*** Settings ***
Library           JSONLibrary
Library           Collections
Library           String
Library           OperatingSystem
Resource          ../../resources/variables/common_variables.robot
Resource         Unique_Random _Note.robot
Resource        create_note_api_keyword.robot

*** Test Cases ***
Create Unique Random Note via Backend and Save Metadata
    [Tags]    API Flow

    ${token}=      create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${note_list}=  Load JSON From File    ${NOTE_CONTENT_FILE}
    ${notes}=      Get Parsed Notes List

    FOR    ${note}    IN    @{note_list}
        ${title}=        Set Variable    ${note['title']}
        ${description}=  Set Variable    ${note['description']}
        ${category}=     Set Variable    ${note['category']}

        ${exists}=       Note Already Exists
        ...              ${notes}    ${title}    ${description}    ${category}

        Run Keyword If    '${exists}' == 'False'    Unique_Random _Note.Create Note And Save Metadata
        ...              ${title}    ${description}    ${category}    ${token}
        Run Keyword If    '${exists}' == 'False'    Log To Console     Created new note: ${title}
        Run Keyword If    '${exists}' == 'False'    Exit For Loop
        Log To Console     Skipped existing note: ${title}
    END

