#*** Settings ***
#Library    RESTLibrary
#Library    OperatingSystem
#Library    String
#Library    Collections
#Resource     ../../Resources/variables/common_variables.robot
#Resource    display_note_keywords.robot

#*** Variables ***
#${BASE_URL}              https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}        /users/login
#${GET_NOTE_ENDPOINT}     /notes
#${NOTE_META_FILE}        data/note_meta.txt
#${EMAIL}                 rakeshkp668@gmail.com
#${PASSWORD}              Rakesh@123

#*** Test Cases ***
#Display Created Note Details
#    ${note_id}=    Read Note ID From File
#    ${token}=      Authenticate And Get Token
#    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
#    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}/${note_id}
#
#    Log To Console     🔐 Sending GET request for note ID: ${note_id}
#    ${response}=    Make HTTP Request
#    ...    requestId=get_note
#    ...    url=${endpoint}
#    ...    method=GET
#    ...    requestHeaders=${headers}
#    ...    responseVerificationType=none
#
#    ${status}=    Set Variable    ${response.responseStatusCode}
#    Run Keyword If    ${status} != 200    Fail    ❌ GET failed with status code ${status}
#
#    ${body}=    Evaluate    json.loads("""${response.responseBody}""")    json
#    ${note}=    Get From Dictionary    ${body}    data
#
#    ${title}=       Get From Dictionary    ${note}    title
#    ${desc}=        Get From Dictionary    ${note}    description
#    ${category}=    Get From Dictionary    ${note}    category
#
#    Log To Console     ✅ Status Code: ${status}
#    Log To Console     🏷️ Title: ${title}
#    Log To Console     📝 Description: ${desc}
#    Log To Console     📂 Category: ${category}
#
#*** Keywords ***
#Read Note ID From File
#
#    ${line}=    Get File    ${NOTE_META_FILE}
#    ${line}=    Strip String    ${line}
#    ${parts}=   Split String    ${line}    |
#    ${note_id}=    Set Variable    ${parts[0]}
#    RETURN    ${note_id}
#
#Authenticate And Get Token
#    ${EMAIL}=            Get Environment Variable        EMAIL
#    ${PASSWORD}=        Get Environment Variable        PASSWORD
#    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Accept=application/json
#    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
#
#    ${response}=    Make HTTP Request
#    ...    requestId=login
#    ...    url=${BASE_URL}${LOGIN_ENDPOINT}
#    ...    method=POST
#    ...    requestHeaders=${headers}
#    ...    requestBody=${body}
#    ...    responseVerificationType=none
#
#    ${status}=    Set Variable    ${response.responseStatusCode}
#    Run Keyword If    ${status} != 200    Fail     Login failed with status code ${status}
#
#    ${body}=    Evaluate    json.loads("""${response.responseBody}""")    json
#    ${data}=    Get From Dictionary    ${body}    data
#    ${token}=   Get From Dictionary    ${data}    token
#    RETURN    ${token}
*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    JSONLibrary
Library    Collections
Library    String
Resource   display_note_keywords.robot
Resource   ../../Resources/variables/common_variables.robot

*** Test Cases ***
Display Created Note Details
    ${token}=    Authenticate And Get Token
    Display First Note Details    ${token}
