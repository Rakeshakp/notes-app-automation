*** Settings ***
Library          ../../ui/Library/NoteLibrary.py
Library          RESTLibrary
Library          JSONLibrary
Library          Collections
Library          String
Library          OperatingSystem

Resource         ../../Resources/variables/common_variables.robot
Resource         validate_note_keyword.robot
Resource         create_note_api_keyword.robot
Resource         delete_note_keywords.robot
Resource         update_profile_keyword.robot
Resource         update_note_keywords.robot
Resource         get_display_all_notes_keyword.robot
Resource         invalid_login_keyword.robot
Resource         negative_note_keyword.robot
Resource         logout_user_keywords.robot
Resource         Unique_Random_Note.robot
Resource         group_notes_by_category_keyword.robot
Resource        note_analysis_keywords.robot
Resource        get_display_completed_notes_keyword.robot


*** Test Cases ***
Create Note from UI
    [Tags]     UI Flow
    Login To Note App
    ${title}    ${description}    ${category}=    update_note_keywords.Read Random Note Content From JSON
    Create Note          ${title}    ${description}    ${category}
    Verify Note Visible  ${title}
    Save Note Metadata   ${title}    ${description}    ${category}
    #Close Browser
    Log To Console         Note created via UI and browser closed

Update and Validate User Profile
    [Tags]    Full Flow  API and UI
    #  Authenticate and update profile via backend
    #  Generate dynamic profile data
    ${name}=         Generate Random String    6    [LETTERS]
    ${phone}=        Generate Random String    10   [NUMBERS]
    ${company}=      Generate Random String    8    [LETTERS]
    ${token}=    create_note_api_keyword.Login And Get Token
    Log    Generated → Name=${name}, Phone=${phone}, Company=${company}    INFO

    ${UPDATED_NAME}    ${UPDATED_PHONE}    ${UPDATED_COMPANY}=    Update Profile And Return Values
    ...    ${token}    ${name}    ${phone}    ${company}
    Log      Backend profile update complete
    #  Launch app and validate profile via UI
    Launch Note App
    Login To Note App
    Go To Profile Page
    Verify Profile Details     ${UPDATED_NAME}    ${UPDATED_PHONE}    ${UPDATED_COMPANY}
    Close Browser
    Log       Profile updated via API and verified via UI
    Log      UI shows: Name=${UPDATED_NAME}, Phone=${UPDATED_PHONE}, Company=${UPDATED_COMPANY}

Validate ui created note via api
    [Tags]     UI Flow
    ${title}    ${description}    ${category}=    validate_note_keyword.Read Note Meta From File
    ${token}=    create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${notes}=    Get Notes List    ${headers}
    ${note_id}=    validate_note_keyword.Find Note ID By Metadata
    ...    ${notes}    ${title}    ${description}    ${category}
    Run Keyword If    '${note_id}' == 'None'    Fail    Note not found in backend
    ${note_url}=    Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}/${note_id}
    Make HTTP Request
    ...    requestId=get_note
    ...    url=${note_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${note_body}=    Execute RC    <<<rc, get_note, body>>
    Log To Console     Note body: ${note_body}

Create Unique Random Note via Backend
    [Tags]    API Flow
    ${token}=      create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${note_list}=  Load JSON From File    ${NOTE_CONTENT_FILE}
    ${notes}=      Unique_Random_Note.Get Parsed Notes List

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
Validate api created Note via UI
    [Tags]     UI Flow
    Launch Note App
    ${note_id}    ${title}    ${description}    ${category}=    update_note_keywords.Read Note Metadata
    Login To Note App
    Validate Note From Metadata
    Log To Console         Backend note validated via UI
    Close Browser
Delete Note using API
    [Tags]     API Flow
    ${login_url}=    Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
    ${token}=        create_note_api_keyword.Login And Get Token
    ${note_id}=      delete_note_keywords.Read Note ID From Metadata
    ${delete_url}=   Set Variable    ${BASE_URL}${CREATE_NOTE_ENDPOINT}/${note_id}
    delete_note_keywords.Delete Note By ID    ${delete_url}    ${token}    ${note_id}
Validate api deleted Note via UI
    [Tags]     UI Flow
    Launch Note App
    ${note_id}    ${title}    ${description}    ${category}=    update_note_keywords.Read Note Metadata
    Login To Note App
    Validate Note Is Not Visible In UI
    Log To Console         Backend note validated via UI
    Close Browser
Update note via UI
    [Tags]    UI Flow
    Launch Note App
    ${note_id}    ${title}    ${description}    ${category}=     update_note_keywords.Read Note Metadata
    Login To Note App
    Validate Note From Metadata
    ${title}    ${description}    ${category}=     update_note_keywords.Read Random Note Content From JSON
    Update Note          ${title}    ${description}    ${category}
    Save Note Metadata   ${title}    ${description}    ${category}
    Close Browser
    Log To Console         Note updated via UI and browser closed
    Close Browser
Validate ui updated Note via api
    [Tags]     APi Flow
    ${title}    ${description}    ${category}=    validate_note_keyword.Read Note Meta From File
    ${token}=    create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}

    ${notes}=    Get Notes List    ${headers}

    ${note_id}=    validate_note_keyword.Find Note ID By Metadata
    ...    ${notes}    ${title}    ${description}    ${category}
    #Run Keyword If    '${note_id}' == 'None'    Fail    Note not found in backend

    ${note_url}=    Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}/${note_id}

    Make HTTP Request
    ...    requestId=get_note
    ...    url=${note_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${note_body}=    Execute RC    <<<rc, get_note, body>>

Extract all Notes
    [Tags]     API Flow
    ${token}=     create_note_api_keyword.Login And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Log      Sending GET request to fetch all notes
    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${notes}=    get_display_all_notes_keyword.Get Parsed Notes List
    ${count}=    Get Length    ${notes}

    Log       Total Notes Found: ${count}

    FOR    ${note}    IN    @{notes}
        ${id}=        Set Variable    ${note['id']}
        ${title}=     Set Variable    ${note['title']}
        ${desc}=      Set Variable    ${note['description']}
        ${category}=  Set Variable    ${note['category']}
        Log        Note ID: ${id}
        Log        Title: ${title}
        Log        Description: ${desc}
        Log        Category: ${category}
    END
Unregistered User Login Should Fail But Test Should Pass
    [Tags]    Negative Testcase    API Flow
    #  Generate dynamic components
    ${prefix}=     Generate Random String    6    [LETTERS]
    ${domain}=     Generate Random String    5    [LETTERS]
    ${email}=      Set Variable    ${prefix}@${domain}.com

    ${pass_prefix}=    Generate Random String    4    [LETTERS]
    ${pass_suffix}=    Generate Random String    4    [NUMBERS]
    ${password}=       Set Variable    ${pass_prefix}${pass_suffix}
    Log     Trying login with: ${email} / ${password}
    #  Expect login to fail
    Run Keyword And Expect Error    *Status code verification failed*    Attempt Login Via API    ${email}    ${password}
    Log To Console      Login failed as expected for unregistered user

Create Note With Missing Description Should Fail
    [Tags]    Negative Testcase    API Flow
    ${token}=    create_note_api_keyword.Login And Get Token
    Run Keyword And Expect Error    *Status code verification failed*    Create Invalid Note With Missing Description    ${token}
    Log To Console     Note creation failed as expected due to missing description
Logout User Session
    [Tags]      API Flow
    #  Get token using Doppler secrets
    ${token}=    create_note_api_keyword.Login And Get Token
    #  Construct logout URL
    ${logout_url}=   Set Variable    ${BASE_URL}${LOGOUT_ENDPOINT}
    #  Perform logout
    Logout User      ${logout_url}    ${token}
    Log To Console     User session successfully logged out

Validate Note Count based on category in API vs UI
    [Tags]    Full Flow    API and UI
    ${token}=     create_note_api_keyword.Login And Get Token
    ${headers}=   Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=  Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${category_map}=    group_notes_by_category_keyword.Group Notes By Category Using RC
    Launch Note App
    Login To Note App
    ${ui_counts}=    Extract Note Count For Each Category    Home    Work    Personal

    FOR    ${category}    IN    @{category_map.keys()}
        ${api_count}=    Get From Dictionary    ${category_map}    ${category}
        ${ui_count}=     Get From Dictionary    ${ui_counts}       ${category}
        Should Be Equal As Integers    ${ui_count}    ${api_count}
        Log To Console     ${category}: UI=${ui_count}, API=${api_count}
    END
    Close Browser
Count Notes Created Today via Api
    [Tags]    Positive testcase    API Flow
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
Validate Today’s created notes In UI
    [Tags]    positive testcase    ui Flow
    Launch Note App
    Login To Note App
    Log Today Notes With Timestamps
    Close Browser
Update Note to complete status in ui
    [Tags]    positive Testcase    Ui Flow
    Launch Note App
    Login To Note App
    Validate Note From Metadata
    Update Note to complete status
    Log        Note status updated via UI and browser closed
    Close Browser
Extract Completed status notes only
    [Tags]    positive Testcase    API Flow
    ${token}=     create_note_api_keyword.Login And Get Token
    ${headers}=   Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=  Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}
    Log    Sending GET request to fetch all notes
    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${notes}=    get_display_all_notes_keyword.Get Parsed Notes List
    ${completed_notes}=    Filter Completed Notes    ${notes}
    ${count}=    Get Length    ${completed_notes}
    Log     Total Completed Notes Found: ${count}
    FOR    ${note}    IN    @{completed_notes}
        ${id}=        Set Variable    ${note['id']}
        ${title}=     Set Variable    ${note['title']}
        ${desc}=      Set Variable    ${note['description']}
        ${category}=  Set Variable    ${note['category']}
        Log     Completed Note ID: ${id}
        Log    Title: ${title}
        Log    Description: ${desc}
        Log    Category: ${category}
    END
Create Note With Missing Title Should Fail
    [Tags]    Negative Testcase    API Flow
    ${token}=    create_note_api_keyword.Login And Get Token
    Run Keyword And Expect Error    *Status code verification failed*    Create Invalid Note With Missing Title    ${token}
    Log To Console     Note creation failed as expected due to missing title
