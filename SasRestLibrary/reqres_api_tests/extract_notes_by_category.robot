*** Settings ***
Library           RESTLibrary
Library           Collections
Library           String
Resource          ../../resources/variables/common_variables.robot
Resource          group_notes_by_category_keyword.robot
Resource          create_note_api_keyword.robot

*** Test Cases ***
Extract Notes Grouped By Category
    [Tags]    API Flow

    ${token}=     create_note_api_keyword.Login And Get Token
    ${headers}=   Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=  Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Log To Console     Sending GET request to fetch all notes
    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${category_map}=    group_notes_by_category_keyword.Group Notes By Category Using RC

    Log To Console      Notes grouped by category:

    ${keys}=           Get Dictionary Keys    ${category_map}
    Sort List          ${keys}

    FOR    ${category}    IN    @{keys}
        ${note_count}=    Get From Dictionary    ${category_map}    ${category}
        Log To Console    ${SPACE * 5}${category}: ${note_count} notes
    END
