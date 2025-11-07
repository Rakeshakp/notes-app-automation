*** Settings ***
Library    RESTLibrary
Library    DateTime
Library    JSONLibrary
Library    Collections
Library    String
Resource   ../../Resources/variables/common_variables.robot
Resource   note_analysis_keywords.robot
Resource   create_note_api_keyword.robot

*** Test Cases ***
Count Notes Created Today
    [Tags]    API Flow

    ${token}=     create_note_api_keyword.Login And Get Token
    ${headers}=   Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=  Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Log    Sending GET request to fetch all notes
    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    expectedStatusCode=200
    ...    responseVerificationType=none

    ${today_notes}=    Get Notes Created Today    get_all_notes
    Log Notes Summary    ${today_notes}
