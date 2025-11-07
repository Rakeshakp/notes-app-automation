*** Settings ***
Library           RESTLibrary
Library           JSONLibrary
Library           String
Library           Collections
Library           OperatingSystem

Resource          ../../resources/variables/common_variables.robot
Resource          update_note_keywords.robot
Resource          create_note_api_keyword.robot
Resource          update_note_negative_keywords.robot

#Suite Setup       Log     Starting Negative Test Suite: Update Note With Invalid ID
#Suite Teardown    Log     Completed Negative Test Suite

*** Test Cases ***
Update Note With Invalid ID Should Fail
    [Tags]    Negative Testcase    API Flow
    # Step 1: Get a valid authentication token
    ${auth_token}=   create_note_api_keyword.Login And Get Token
    # Step 2: Generate random note content from JSON
    ${title}    ${description}    ${category}=    update_note_keywords.Read Random Note Content From JSON
    # Step 3: Dynamically generate an invalid note ID based on existing notes
    ${invalid_note_id}=    update_note_negative_keywords.Generate Truly Invalid Note ID    ${auth_token}
    # Step 4: Set completed status (can be static or dynamic)
    ${completed}=    Set Variable    False
    # Step 5: Attempt update and expect failure
    Run Keyword And Expect Error    *Status code verification failed*    update_note_negative_keywords.Update Note With Invalid ID Using RC
    ...    ${invalid_note_id}
    ...    ${title}
    ...    ${description}
    ...    ${category}
    ...    ${completed}
    ...    ${auth_token}

    Log To Console      Update failed as expected for invalid note ID: ${invalid_note_id}
