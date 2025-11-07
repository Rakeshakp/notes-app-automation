#*** Settings ***
#Library    RESTLibrary
#Library    OperatingSystem
#Library    String
#Library    Collections
#
#*** Variables ***
#${BASE_URL}              https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}        /users/login
#${EMAIL}                 rakeshkp668@gmail.com
#${PASSWORD}              Rakesh@123
#${NOTE_META_FILE}        data/note_meta.txt
#${GET_NOTE_ENDPOINT}     /notes
##
###*** Test Cases ***
###Get Private Note By ID Using RESTLibrary
###    ${note_id}=    Read Note ID From File
###    ${token}=      Authenticate And Get Token
###    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
###    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}/${note_id}
###
###    Log To Console     🔐 Sending authenticated GET request for note ID: ${note_id}
####    ${request}=    Generate HTTP Request
####    ...    requestId=get_note
####    ...    url=${endpoint}
####    ...    method=GET
####    ...    requestHeaders=${headers}
###       ${request_data}=    Create Dictionary
###        ...    requestId=get_note
###        ...    url=${endpoint}
###        ...    method=GET
###        ...    requestHeaders=${headers}
###
###    ${request}=    Generate HTTP Request    ${request_data}
###    ${response}=   Process Http Request    ${request}
###    ${status}=     Get From Dictionary    ${response}    status_code
###
###    Run Keyword If    ${status} != 200    Fail    ❌ GET request failed with status code ${status}
###
###    ${body}=     Get From Dictionary    ${response}    response_body
###    Log To Console     ✅ Status Code: ${status}
###    Log To Console     📄 Response Body: ${body}
###    Log To Console     🎉 Note ${note_id} retrieved successfully!
###
####*** Keywords ***
####Read Note ID From File
####
####    ${line}=    Get File    ${NOTE_META_FILE}
####    ${line}=    Strip String    ${line}
####    ${parts}=   Split String    ${line}    |
####    ${note_id}=    Set Variable    ${parts[0]}
####    Log To Console     🧾 Note ID: ${note_id}
####    Log To Console     🏷️ Title: ${parts[1]}
####    Log To Console     📝 Description: ${parts[2]}
####    Log To Console     📂 Category: ${parts[3]}
####    RETURN    ${note_id}
###Read Note ID From File
###    ${line}=    Get File    ${NOTE_META_FILE}
###    ${line}=    Strip String    ${line}
###    ${parts}=   Split String    ${line}    |
###    ${length}=  Get Length    ${parts}
###    Run Keyword If    ${length} < 3    Fail    ❌ note_meta.txt must contain at least 3 fields
###
###    ${note_id}=       Set Variable    ${parts[0]}
###    ${title}=         Set Variable    ${parts[1]}
###    ${description}=   Set Variable    ${parts[2]}
###
###    Log To Console     🧾 Note ID: ${note_id}
###    Log To Console     🏷️ Title: ${title}
###    Log To Console     📝 Description: ${description}
###
###    RETURN    ${note_id}
###
###
####Authenticate And Get Token
####
####    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Accept=application/json
####    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
####
####    ${request}=    Generate HTTP Request
####    ...    requestId=login
####    ...    url=${BASE_URL}${LOGIN_ENDPOINT}
####    ...    method=POST
####    ...    requestHeaders=${headers}
####    ...    requestBody=${body}
####
####    ${response}=   Process Http Request    ${request}
####    ${status}=     Get From Dictionary    ${response}    status_code
####    Run Keyword If    ${status} != 200    Fail    ❌ Login failed with status code ${status}
####
####    ${body}=       Get From Dictionary    ${response}    response_body
####    ${token}=      Get From Dictionary    ${body}    data.token
####    Log To Console     🔐 Auth Token: ${token}
####    RETURN    ${token}
###Authenticate And Get Token
###    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Accept=application/json
###    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
###    ${endpoint}=   Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
###
###    ${request_data}=    Create Dictionary
###    ...    requestId=login
###    ...    url=${endpoint}
###    ...    method=POST
###    ...    requestHeaders=${headers}
###    ...    requestBody=${body}
###
###    ${request}=    Generate HTTP Request    ${request_data}
###    ${response}=   Process Http Request    ${request}
###    ${status}=     Get From Dictionary    ${response}    status_code
###    Run Keyword If    ${status} != 200    Fail    ❌ Login failed with status code ${status}
###
###    ${body}=       Get From Dictionary    ${response}    response_body
###    ${token}=      Get From Dictionary    ${body}    data.token
###    Log To Console     🔐 Auth Token: ${token}
###    RETURN    ${token}
##*** Test Cases ***
##Get Private Note By ID Using RESTLibrary
##    ${title}    ${description}    ${category}=    Read Note Meta From File
##    ${token}=    Authenticate And Get Token
##    ${headers}=  Create Dictionary    Accept=application/json    x-auth-token=${token}
##
##    ${endpoint}=    Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}
##    ${request_data}=    Create Dictionary
##    ...    requestId=get_notes
##    ...    url=${endpoint}
##    ...    method=GET
##    ...    requestHeaders=${headers}
##
##    ${request}=    Generate HTTP Request    ${request_data}
##    ${response}=   Process Http Request    ${request}
##    ${status}=     Get From Dictionary    ${response}    status_code
##    Run Keyword If    ${status} != 200    Fail    ❌ Failed to fetch notes. Status: ${status}
##
##    ${body}=       Get From Dictionary    ${response}    response_body
##    ${notes}=      Get From Dictionary    ${body}    data
##
##    ${note_id}=    Set Variable    None
##    FOR    ${note}    IN    @{notes}
##        ${t}=    Strip String    ${note['title']}
##        ${d}=    Strip String    ${note['description']}
##        ${c}=    Strip String    ${note['category']}
##        ${t_lower}=    Convert To Lower Case    ${t}
##        ${d_lower}=    Convert To Lower Case    ${d}
##        ${c_lower}=    Convert To Lower Case    ${c}
##        ${title_lower}=    Convert To Lower Case    ${title}
##        ${description_lower}=    Convert To Lower Case    ${description}
##        ${category_lower}=    Convert To Lower Case    ${category}
##        Run Keyword If    '${t_lower}' == '${title_lower}' and '${d_lower}' == '${description_lower}' and '${c_lower}' == '${category_lower}'
##        ...    Set Variable    ${note_id}    ${note['id']}
##        ...    Exit For Loop
##    END
##
##    Run Keyword If    '${note_id}' == 'None'    Fail    ❌ Note not found in backend
##
##    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}/${note_id}
##    ${note_request_data}=    Create Dictionary
##    ...    requestId=get_note
##    ...    url=${endpoint}
##    ...    method=GET
##    ...    requestHeaders=${headers}
##
##    ${request}=    Generate HTTP Request    ${note_request_data}
##    ${response}=   Process Http Request    ${request}
##    ${status}=     Get From Dictionary    ${response}    status_code
##    Run Keyword If    ${status} != 200    Fail    ❌ GET request failed with status code ${status}
##
##    ${body}=     Get From Dictionary    ${response}    response_body
##    Log To Console     ✅ Status Code: ${status}
##    Log To Console     📄 Response Body: ${body}
##    Log To Console     🎉 Note ${note_id} retrieved successfully!
##*** Keywords ***
##Read Note Meta From File
##    ${line}=    Get File    ${NOTE_META_FILE}
##    ${line}=    Strip String    ${line}
##    ${parts}=   Split String    ${line}    |
##    ${length}=  Get Length    ${parts}
##    Run Keyword If    ${length} < 3    Fail    ❌ note_meta.txt must contain title, description, and category
##
##    ${title}=       Set Variable    ${parts[0]}
##    ${description}=  Set Variable    ${parts[1]}
##    ${category}=    Set Variable    ${parts[2]}
##
##    Log To Console     🏷️ Title: ${title}
##    Log To Console     📝 Description: ${description}
##    Log To Console     📂 Category: ${category}
##
##    RETURN    ${title}    ${description}    ${category}
##*** Keywords ***
##Authenticate And Get Token
##    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Accept=application/json
##    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
##    ${endpoint}=   Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
##
##    ${request_data}=    Create Dictionary
##    ...    requestId=login
##    ...    url=${endpoint}
##    ...    method=POST
##    ...    requestHeaders=${headers}
##    ...    requestBody=${body}
##
##    ${request}=    Generate HTTP Request    ${request_data}
##    ${response}=   Process Http Request    ${request}
##    ${status}=     Get From Dictionary    ${response}    status_code
##    Run Keyword If    ${status} != 200    Fail    ❌ Login failed with status code ${status}
##
##    ${body}=       Get From Dictionary    ${response}    response_body
##    ${token}=      Get From Dictionary    ${body}    data.token
##    Log To Console     🔐 Auth Token: ${token}
##    RETURN    ${token}
#*** Test Cases ***
#Get Private Note By ID Using RESTLibrary
#    ${title}    ${description}    ${category}=    Read Note Meta From File
#    ${token}=    Authenticate And Get Token
#    ${headers}=  Create Dictionary    Accept=application/json    x-auth-token=${token}
#
#    ${endpoint}=    Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}
#    ${request_data}=    Create Dictionary
#    ...    requestId=get_notes
#    ...    url=${endpoint}
#    ...    method=GET
#    ...    requestHeaders=${headers}
#
#    ${request_info}=    Set Variable    ${request_data}
#    ${request}=    Generate HTTP Request    ${request_info}
#    ${response}=   Process Http Request    ${request}
#    ${status}=     Get From Dictionary    ${response}    status_code
#    Run Keyword If    ${status} != 200    Fail    ❌ Failed to fetch notes. Status: ${status}
#
#    ${body}=       Get From Dictionary    ${response}    response_body
#    ${notes}=      Get From Dictionary    ${body}    data
#
#    ${note_id}=    Set Variable    None
#    FOR    ${note}    IN    @{notes}
#        ${t}=    Strip String    ${note['title']}
#        ${d}=    Strip String    ${note['description']}
#        ${c}=    Strip String    ${note['category']}
#        ${t_lower}=    Convert To Lower Case    ${t}
#        ${d_lower}=    Convert To Lower Case    ${d}
#        ${c_lower}=    Convert To Lower Case    ${c}
#        ${title_lower}=    Convert To Lower Case    ${title}
#        ${description_lower}=    Convert To Lower Case    ${description}
#        ${category_lower}=    Convert To Lower Case    ${category}
#        Run Keyword If    '${t_lower}' == '${title_lower}' and '${d_lower}' == '${description_lower}' and '${c_lower}' == '${category_lower}'
#        ...    Run Keywords    Set Variable    ${note_id}    ${note['id']}    AND    Exit For Loop
#    END
#
#    Run Keyword If    '${note_id}' == 'None'    Fail    ❌ Note not found in backend
#
#    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTE_ENDPOINT}/${note_id}
#    ${note_request_data}=    Create Dictionary
#    ...    requestId=get_note
#    ...    url=${endpoint}
#    ...    method=GET
#    ...    requestHeaders=${headers}
#    ...    requestBody=${body}
#
#    ${note_request_info}=    Set Variable    ${note_request_data}
#    ${request}=    Generate HTTP Request    ${note_request_info}
#    ${response}=   Process Http Request    ${request}
#    ${status}=     Get From Dictionary    ${response}    status_code
#    Run Keyword If    ${status} != 200    Fail    ❌ GET request failed with status code ${status}
#
#    ${body}=     Get From Dictionary    ${response}    response_body
#    Log To Console     ✅ Status Code: ${status}
#    Log To Console     📄 Response Body: ${body}
#    Log To Console     🎉 Note ${note_id} retrieved successfully!
#*** Keywords ***
#Read Note Meta From File
#    ${line}=    Get File    ${NOTE_META_FILE}
#    ${line}=    Strip String    ${line}
#    ${parts}=   Split String    ${line}    |
#    ${length}=  Get Length    ${parts}
#    Run Keyword If    ${length} < 3    Fail    ❌ note_meta.txt must contain title, description, and category
#
#    ${title}=       Set Variable    ${parts[0]}
#    ${description}=  Set Variable    ${parts[1]}
#    ${category}=    Set Variable    ${parts[2]}
#
#    Log To Console     🏷️ Title: ${title}
#    Log To Console     📝 Description: ${description}
#    Log To Console     📂 Category: ${category}
#
#    RETURN    ${title}    ${description}    ${category}
#
#
#Authenticate And Get Token
#    ${headers}=    Create Dictionary    Content-Type=application/x-www-form-urlencoded    Accept=application/json
#    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
#    ${endpoint}=   Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
#
#    ${request_data}=    Create Dictionary
#    ...    requestId=login
#    ...    url=${endpoint}
#    ...    method=POST
#    ...    requestHeaders=${headers}
#    ...    requestBody=${body}
#    ...    requestBody=${body}
#
#    ${request_info}=    Set Variable    ${request_data}
#    ${request}=    Generate HTTP Request    ${request_info}
#    ${response}=   Process Http Request    ${request}
#    ${status}=     Get From Dictionary    ${response}    status_code
#    Run Keyword If    ${status} != 200    Fail    ❌ Login failed with status code ${status}
#
#    ${body}=       Get From Dictionary    ${response}    response_body
#    ${token}=      Get From Dictionary    ${body}    data.token
#    Log To Console     🔐 Auth Token: ${token}
#    RETURN    ${token}
*** Settings ***
Library           RESTLibrary
Library           Collections
Library           String
Library           OperatingSystem
Library           JSONLibrary
Resource          ../../Resources/variables/common_variables.robot
Resource          validate_note_keyword.robot

*** Test Cases ***
Get Private Note By ID Using RESTLibrary
    ${title}    ${description}    ${category}=    Read Note Meta From File
    ${token}=    Authenticate And Get Token

    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${notes_url}=  Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    ${notes_response}=   Make HTTP Request
    ...    requestId=get_notes
    ...    url=${notes_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${status}=     Set Variable    ${notes_response.responseStatusCode}
    Run Keyword If    ${status} != 200    Fail     Failed to fetch notes. Status: ${status}

    ${raw_body}=   Set Variable    ${notes_response.responseBody}
    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
    ${notes}=      Get From Dictionary    ${body}    data

    ${note_id}=    Find Note ID By Metadata    ${notes}    ${title}    ${description}    ${category}
    Run Keyword If    '${note_id}' == 'None'    Fail     Note not found in backend

    ${note_url}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}/${note_id}
    ${note_response}=   Make HTTP Request
    ...    requestId=get_note
    ...    url=${note_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${status}=     Set Variable    ${note_response.responseStatusCode}
    Run Keyword If    ${status} != 200    Fail     GET request failed with status code ${status}

    ${raw_body}=   Set Variable    ${note_response.responseBody}
    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
#    Log To Console      Status Code: ${status}
#    Log To Console      Response Body: ${body}
#    Log To Console      Note ${note_id} retrieved successfully!
