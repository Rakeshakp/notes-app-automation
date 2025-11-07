*** Settings ***
Library    RESTLibrary
Library    Collections
Library    String
Library    BuiltIn
Resource    ../../Resources/variables/common_variables.robot

*** Keywords ***
Create Invalid Note With Missing Title
    [Arguments]    ${token}

    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Content-Type=application/x-www-form-urlencoded
    ...    x-auth-token=${token}
    ${payload}=    Set Variable    title=&description=Missing Title Test&category=General
    ${url}=        Set Variable    ${BASE_URL}${CREATE_NOTE_ENDPOINT}

    Make HTTP Request
    ...    requestId=create_note_missing_title
    ...    url=${url}
    ...    method=POST
    ...    requestHeaders=${headers}
    ...    requestBody=${payload}
    ...    responseVerificationType=none

    # Validate status code
    ${status}=    Execute RC    <<<rc, create_note_missing_title, status>>
    Should Be Equal As Integers    ${status}    400

    # Extract error message using RC
    ${error_message}=    Execute RC    <<<rc, create_note_missing_title, body, $.message>>
    Log To Console     Note creation failed as expected - ${error_message}
