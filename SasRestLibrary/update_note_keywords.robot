*** Settings ***
Library    RESTLibrary
Library    JSONLibrary
Library    Collections
Library    String
Library    OperatingSystem

Resource         ../../resources/variables/common_variables.robot

*** Keywords ***
Read Note Metadata
    ${content}=    Get File    ${NOTE_META_FILE}
    ${parts}=      Split String    ${content}    |
    ${note_id}=        Strip String    ${parts[0]}
    ${title}=          Strip String    ${parts[1]}
    ${description}=    Strip String    ${parts[2]}
    ${category}=       Strip String    ${parts[3]}
    RETURN        ${note_id}    ${title}    ${description}    ${category}

Read Random Note Content From JSON
    ${json_text}=    Get File    ${NOTE_CONTENT_FILE}
    ${data}=         Evaluate    json.loads("""${json_text}""")    json
    ${length}=       Get Length    ${data}
    ${index}=        Evaluate    random.randint(0, ${length} - 1)    random
    ${note}=         Set Variable    ${data}[${index}]
    ${title}=        Set Variable    ${note['title']}
    ${description}=  Set Variable    ${note['description']}
    ${category}=     Set Variable    ${note['category']}
    RETURN       ${title}    ${description}    ${category}

Get Auth Token
    [Arguments]    ${email}    ${password}
    ${headers}=    Create Dictionary
    ...            Content-Type=application/x-www-form-urlencoded
    ...            Accept=application/json
    ${payload}=    Set Variable    email=${email}&password=${password}
    ${login_url}=  Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
    ${response}=   Make HTTP Request
    ...            login_request
    ...            ${login_url}
    ...            method=POST
    ...            requestBody=${payload}
    ...            expectedStatusCode=200
    ...            requestDataType=text
    ...            responseVerificationType=Partial
    ...            requestHeaders=${headers}
    ${raw_body}=   Set Variable    ${response.responseBody}
    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
    ${auth_token}=    Get From Dictionary    ${body['data']}    token
    ${auth_token}=    Strip String    ${auth_token}
    RETURN         ${auth_token}

Get Note Completed Status
    [Arguments]    ${note_url}    ${auth_token}
    Log To Console     Using token: ${auth_token}
    Log To Console     Requesting note status from: ${note_url}
    ${headers}=    Create Dictionary
    ...            Accept=application/json
    ...            x-auth-token=${auth_token}
    Make HTTP Request
    ...    requestId=get_note_request
    ...    url=${note_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    expectedStatusCode=200
    ...    responseDataType=json
    ...    responseVerificationType=none
    RETURN FROM KEYWORD    <<<rc, get_note_request, body, $.data.completed>>>
Update Note Fields
    [Arguments]    ${note_url}    ${auth_token}    ${note_id}    ${title}    ${description}    ${category}    ${completed}
    ${note_id}=        Strip String    ${note_id}
    ${title}=          Strip String    ${title}
    ${description}=    Strip String    ${description}
    ${category}=       Strip String    ${category}
    ${completed}=      Convert To Boolean    ${completed}

    ${headers}=    Create Dictionary
    ...            Content-Type=application/json
    ...            Accept=application/json
    ...            x-auth-token=${auth_token}

    ${payload}=    Create Dictionary
    ...            title=${title}
    ...            description=${description}
    ...            category=${category}
    ...            completed=${completed}

    ${payload_json}=    Evaluate    json.dumps(${payload})    json
    Make HTTP Request
    ...    requestId=update_note_request
    ...    url=${note_url}
    ...    method=PUT
    ...    requestBody=${payload_json}
    ...    expectedStatusCode=200
    ...    requestHeaders=${headers}
    ...    requestDataType=json
    ...    responseDataType=json
    ...    responseVerificationType=none

    ${updated_title}=        RETURN FROM KEYWORD    <<<rc, update_note_request, body, $.data.title>>
    ${updated_description}=  RETURN FROM KEYWORD    <<<rc, update_note_request, body, $.data.description>>
    ${updated_category}=     RETURN FROM KEYWORD    <<<rc, update_note_request, body, $.data.category>>

    Update Note Metadata File    ${note_id}    ${updated_title}    ${updated_description}    ${updated_category}

Update Note Metadata File
    [Arguments]    ${note_id}    ${title}    ${description}    ${category}
    ${new_content}=    Set Variable    ${note_id}|${title}|${description}|${category}
    Create File    ${NOTE_META_FILE}    ${new_content}
