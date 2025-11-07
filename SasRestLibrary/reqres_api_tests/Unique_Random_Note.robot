*** Settings ***
Library           RESTLibrary
Library           JSONLibrary
Library           Collections
Library           String
Library           OperatingSystem
Resource          ../../resources/variables/common_variables.robot
Library           ../../ui/Library/NoteLibrary.py

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

    ${token}=    Execute RC    <<<rc, login_request, body, $.data.token>>>
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

    ${note_id}=    Execute RC    <<<rc, create_note_request, body, $.data.id>>>
    ${note_meta}=  Set Variable    ${note_id}|${title}|${description}|${category}
    Remove File    ${NOTE_META_FILE}
    Create File    ${NOTE_META_FILE}   ${note_meta}\n
    Log To Console     Note metadata saved to file: ${note_meta}
Get Parsed Notes List
    ${token}=      Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${notes_json}=    Execute RC    <<<rc, get_all_notes, body, $.data>>>
    Should Not Be Empty    ${notes_json}     API response body is empty or malformed
    ${notes}=    Evaluate    __import__('json').loads(r'''${notes_json}''')    json
    RETURN            ${notes}

Note Already Exists
    [Arguments]    ${notes}    ${title}    ${description}    ${category}
    ${title_norm}=        Normalize String    ${title}
    ${description_norm}=  Normalize String    ${description}
    ${category_norm}=     Normalize String    ${category}

    FOR    ${note}    IN    @{notes}
        ${t_norm}=    Normalize String    ${note['title']}
        ${d_norm}=    Normalize String    ${note['description']}
        ${c_norm}=    Normalize String    ${note['category']}

        ${match}=     Evaluate    '${t_norm}' == '${title_norm}' and '${d_norm}' == '${description_norm}' and '${c_norm}' == '${category_norm}'
        Run Keyword If    ${match}    Return From Keyword    True
    END
    Return From Keyword    False

Normalize String
    [Arguments]    ${text}
    ${text}=    Strip String    ${text}
    ${text}=    Replace String    ${text}    \n    ${EMPTY}
    ${text}=    Replace String    ${text}    \r    ${EMPTY}
    ${text}=    Convert To Lower Case    ${text}
    RETURN      ${text}
