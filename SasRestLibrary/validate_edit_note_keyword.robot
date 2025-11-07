*** Settings ***
Library           RESTLibrary
Library           Collections
Library           String
Library           JSONLibrary
Library           OperatingSystem

Resource          ../../Resources/variables/common_variables.robot
Resource          create_note_api_keyword.robot
Resource          validate_note_keyword.robot
Resource          update_note_keywords.robot

*** Keywords ***
Validate UI Edited Note via API
    [Arguments]    ${expected_title}    ${expected_description}    ${expected_category}

    # Step 1: Authenticate and prepare headers
    ${token}=    create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}

    # Step 2: Get list of notes and find the updated note ID
    ${notes}=    validate_note_keyword.Get Notes List    ${headers}
    ${note_id}=    validate_note_keyword.Find Note ID By Metadata
    ...    ${notes}    ${expected_title}    ${expected_description}    ${expected_category}
    Run Keyword If    '${note_id}' == 'None'    Fail    Note not found in backend after UI edit

    # Step 3: Build and send GET request for the specific note
    ${note_url}=    Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}/${note_id}
    ${empty_files}=    Create Dictionary
    ${requestInfo}=    Create Dictionary
    ...    requestid=get_note
    ...    url=${note_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    authType=NoAuth
    ...    files=${empty_files}
    ...    requestBody=
    ...    requestBodyFilePath=
    ...    timeout=30

    ${requestInfo}=    Generate HTTP Request    ${requestInfo}
    Process Http Request    ${requestInfo}

    # Step 4: Extract and validate response body
    ${note_body}=    Execute RC    <<<RC, get_note, body>>>
    Log    ${note_body}
    Run Keyword If    '${note_body}' == ''    Fail    API response body is empty for note ID ${note_id}
    ${note_json}=    Evaluate    json.loads("""${note_body}""")    json
    ${data}=    Get From Dictionary    ${note_json}    data

    # Step 5: Validate note content
    Should Be Equal As Strings    ${data['title']}         ${expected_title}
    Should Be Equal As Strings    ${data['description']}   ${expected_description}
    Should Be Equal As Strings    ${data['category']}      ${expected_category}
    Log To Console    ✅ API validation passed for UI-edited note
