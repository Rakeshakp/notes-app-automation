*** Settings ***
Library    RESTLibrary
Library    JSONLibrary
Library    Collections
Library    String
Library    OperatingSystem
Resource          ../../resources/variables/common_variables.robot
Library         ../../ui/Library/NoteLibrary.py

*** Keywords ***
Login And Get Token
    ${secrets}=    Get Doppler Secrets
    ${email}=      Set Variable    ${secrets['EMAIL']}
    ${password}=   Set Variable    ${secrets['PASSWORD']}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/x-www-form-urlencoded
    ...    Accept=application/json

    ${payload}=    Set Variable    email=${email}&password=${password}

    Make HTTP Request
    ...    login_request
    ...    ${BASE_URL}${LOGIN_ENDPOINT}
    ...    method=POST
    ...    requestBody=${payload}
    ...    expectedStatusCode=200
    ...    requestDataType=text
    ...    responseVerificationType=Partial
    ...    requestHeaders=${headers}

    Log    Response status: <<<rc, login_request, statusCode>>>
    Log    Response body: <<<rc, login_request, body>>>
    #  Extract token using RC
    ${token}=    Execute RC    <<<rc, login_request, body, $.data.token>>>
    Log         Extracted token: ${token}
    RETURN      ${token}

Create Note And Save Metadata
    [Arguments]    ${title}    ${description}    ${category}    ${token}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/x-www-form-urlencoded
    ...    Accept=application/json
    ...    x-auth-token=${token}

    ${payload}=    Set Variable    title=${title}&description=${description}&category=${category}

    Make HTTP Request
    ...    create_note_request
    ...    ${BASE_URL}${CREATE_NOTE_ENDPOINT}
    ...    method=POST
    ...    requestHeaders=${headers}
    ...    requestBody=${payload}
    ...    requestDataType=text
    ...    responseDataType=json
    ...    expectedStatusCode=200
    ...    responseVerificationType=none

    Log    Response status: <<<rc, create_note_request, statusCode>>>
    Log    Response body: <<<rc, create_note_request, body>>>

    #  Use RC to extract note ID
    ${note_id}=    Execute RC    <<<rc, create_note_request, body, $.data.id>>>
    Log            Extracted note ID: ${note_id}

    ${note_meta}=    Set Variable    ${note_id}|${title}|${description}|${category}
    Create File     ${NOTE_META_FILE}    ${note_meta}
    Log             Note metadata saved to file: ${note_meta}
