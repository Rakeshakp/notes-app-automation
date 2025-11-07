#*** Settings ***
#Library    RESTLibrary
#Library    String
#Library    Collections
#Library    OperatingSystem
#Resource     ../../Resources/variables/common_variables.robot
#Resource    update_profile_keyword.robot
#
#*** Test Cases ***
#Update User Profile with RESTLibrary
#    ${name}=     Generate Random String    6    [LETTERS]
#    ${phone}=    Generate Random String    10   [NUMBERS]
#    ${company}=  Generate Random String    8    [LETTERS]
#
#    Log     Generated Data → Name: ${name}, Phone: ${phone}, Company: ${company}
#
#    ${token}=    Authenticate And Get Token
#    ${headers}=  Create Dictionary
#    ...    Accept=application/json
#    ...    Content-Type=application/json
#    ...    x-auth-token=${token}
#
#    ${payload}=  Create Dictionary
#    ...    name=${name}
#    ...    phone=${phone}
#    ...    company=${company}
#    ${body}=     Evaluate    json.dumps(${payload})    json
#
#    ${endpoint}=   Set Variable    ${BASE_URL}${UPDATE_PROFILE_ENDPOINT}
#    Log     Sending PATCH request to update profile
#
#    ${response}=    Make HTTP Request
#    ...    requestId=update_profile
#    ...    url=${endpoint}
#    ...    method=PATCH
#    ...    requestHeaders=${headers}
#    ...    requestBody=${body}
#    ...    responseVerificationType=none
#
#    ${status}=    Set Variable    ${response.responseStatusCode}
#    Run Keyword If    ${status} != 200    Fail     Profile update failed with status code ${status}
#
#    ${body}=    Evaluate    json.loads("""${response.responseBody}""")    json
#    ${data}=    Get From Dictionary    ${body}    data
#    ${updated_name}=     Get From Dictionary    ${data}    name
#    ${updated_phone}=    Get From Dictionary    ${data}    phone
#    ${updated_company}=  Get From Dictionary    ${data}    company
#
#    Log     Status Code: ${status}
#    Log     Updated Name: ${updated_name}
#    Log     Updated Phone: ${updated_phone}
#    Log     Updated Company: ${updated_company}
*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Library    RESTLibrary
Library    ../../ui/Library/NoteLibrary.py
Resource   ../../resources/variables/common_variables.robot
Resource   update_profile_keyword.robot

*** Test Cases ***
Update and Validate User Profile
    [Tags]    Full Flow    API and UI Sync

    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD

    #  Generate dynamic profile data
    ${name}=         Generate Random String    6    [LETTERS]
    ${phone}=        Generate Random String    10   [NUMBERS]
    ${company}=      Generate Random String    8    [LETTERS]

    Log      Generated → Name=${name}, Phone=${phone}, Company=${company}
    #  Authenticate and update profile via backend
    ${token}=        Authenticate And Get Token
    ${UPDATED_NAME}    ${UPDATED_PHONE}    ${UPDATED_COMPANY}=    Update Profile And Return Values
    ...    ${token}    ${name}    ${phone}    ${company}
    Log      Backend profile update complete
    #  Launch app and validate profile via UI
    Launch Note App
    Login To Note App      ${EMAIL}    ${PASSWORD}
    Go To Profile Page
    Verify Profile Details    ${UPDATED_NAME}    ${UPDATED_PHONE}    ${UPDATED_COMPANY}
    Close Browser
    Log       Profile updated via API and verified via UI
    Log      UI shows: Name=${UPDATED_NAME}, Phone=${UPDATED_PHONE}, Company=${UPDATED_COMPANY}
