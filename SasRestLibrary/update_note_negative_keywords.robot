*** Settings ***
Library    RESTLibrary
Library    JSONLibrary
Library    String
Library    Collections

Resource   ../../resources/variables/common_variables.robot

*** Keywords ***
Generate Truly Invalid Note ID
    [Arguments]    ${auth_token}

    ${headers}=    Create Dictionary
    ...            Accept=application/json
    ...            x-auth-token=${auth_token}
    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Make HTTP Request
    ...    requestId=get_notes_for_invalid_id
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    # Step 1: Get the raw JSON string from RC
       ${raw_data}=    Execute RC    <<<rc, get_notes_for_invalid_id, body>>

    # Step 2: Parse it using Python's json.loads
        ${parsed}=    Evaluate    json.loads("""${raw_data}""")    json

    # Step 3: Extract the notes list
        ${notes}=    Set Variable    ${parsed['data']}


    Log    Notes parsed output: ${notes}
    Should Be True    ${notes} != None
    Should Be True    ${notes} != ''
    ${length}=    Get Length    ${notes}
    Should Be True    ${length} > 0

    ${existing_ids}=    Create List
    FOR    ${note}    IN    @{notes}
        ${id}=    Convert To Integer    ${note['id']}
        Append To List    ${existing_ids}    ${id}
    END

    ${max_id}=    Evaluate    max(${existing_ids})    existing_ids
    ${invalid_id}=    Evaluate    ${max_id} + 1

    RETURN    ${invalid_id}
