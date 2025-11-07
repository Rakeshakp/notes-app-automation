*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    JSONLibrary
Library    Collections
Library    String

#*** Variables ***
#${BASE_URL}               https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}         ${BASE_URL}/users/login
#${UPDATE_NOTE_ENDPOINT}   ${BASE_URL}/notes
#${NOTE_META_FILE}         data/note_meta.txt
#${NOTE_CONTENT_FILE}      data/note_content.json
#${EMAIL}                  rakeshkp668@gmail.com
#${PASSWORD}               Rakesh@123

#*** Test Cases ***
#Update Note via Backend
#    ${note_id}    ${old_title}    ${old_description}    ${old_category}=    Read Note Metadata
#    ${title}    ${description}    ${category}=    Read Random Note Content From JSON
#    ${token}=    Get Auth Token    ${EMAIL}    ${PASSWORD}
#    ${completed}=    Get Note Completed Status    ${token}    ${note_id}
#    Update Note Fields    ${token}    ${note_id}    ${title}    ${description}    ${category}    ${completed}
#
#*** Keywords ***
#Read Note Metadata
#    ${content}=    Get File    ${NOTE_META_FILE}
#    ${parts}=      Split String    ${content}    |
#    ${note_id}=        Strip String    ${parts[0]}
#    ${title}=          Strip String    ${parts[1]}
#    ${description}=    Strip String    ${parts[2]}
#    ${category}=       Strip String    ${parts[3]}
#    RETURN        ${note_id}    ${title}    ${description}    ${category}
#
#Read Random Note Content From JSON
#    ${json_text}=    Get File    ${NOTE_CONTENT_FILE}
#    ${data}=         Evaluate    json.loads("""${json_text}""")    json
#    ${length}=       Get Length    ${data}
#    ${index}=        Evaluate    random.randint(0, ${length} - 1)    random
#    ${note}=         Set Variable    ${data}[${index}]
#    ${title}=        Set Variable    ${note['title']}
#    ${description}=  Set Variable    ${note['description']}
#    ${category}=     Set Variable    ${note['category']}
#    RETURN       ${title}    ${description}    ${category}
#
#Get Auth Token
#    [Arguments]    ${email}    ${password}
#    ${headers}=    Create Dictionary
#    ...            Content-Type=application/x-www-form-urlencoded
#    ...            Accept=application/json
#    ${payload}=    Set Variable    email=${email}&password=${password}
#    ${response}=   Make HTTP Request
#    ...            login_request
#    ...            ${LOGIN_ENDPOINT}
#    ...            method=POST
#    ...            requestBody=${payload}
#    ...            expectedStatusCode=200
#    ...            requestDataType=text
#    ...            responseVerificationType=Partial
#    ...            requestHeaders=${headers}
#    ${raw_body}=   Set Variable    ${response.responseBody}
#    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
#    ${token}=      Get From Dictionary    ${body['data']}    token
#    ${token}=      Strip String    ${token}
#    RETURN         ${token}
#
#Get Note Completed Status
#    [Arguments]    ${token}    ${note_id}
#    ${headers}=    Create Dictionary
#    ...            Accept=application/json
#    ...            x-auth-token=${token}
#    ${endpoint}=   Set Variable    ${UPDATE_NOTE_ENDPOINT}/${note_id}
#    ${response}=   Make HTTP Request
#    ...            get_note_request
#    ...            ${endpoint}
#    ...            method=GET
#    ...            requestHeaders=${headers}
#    ...            expectedStatusCode=200
#    ...            responseDataType=json
#    ...            responseVerificationType=none
#    ${raw_body}=   Set Variable    ${response.responseBody}
#    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
#    ${completed}=  Convert To String    ${body['data']['completed']}
#    ${completed}=  Strip String    ${completed}
#    RETURN         ${completed}
#
#Update Note Fields
#    [Arguments]    ${token}    ${note_id}    ${title}    ${description}    ${category}    ${completed}
#    ${token}=          Strip String    ${token}
#    ${note_id}=        Strip String    ${note_id}
#    ${title}=          Strip String    ${title}
#    ${description}=    Strip String    ${description}
#    ${category}=       Strip String    ${category}
#    ${completed}=      Convert To Boolean    ${completed}
#
#    ${headers}=    Create Dictionary
#    ...            Content-Type=application/json
#    ...            Accept=application/json
#    ...            x-auth-token=${token}
#
#    ${payload}=    Create Dictionary
#    ...            title=${title}
#    ...            description=${description}
#    ...            category=${category}
#    ...            completed=${completed}
#
#    ${endpoint}=   Set Variable    ${UPDATE_NOTE_ENDPOINT}/${note_id}
#    ${payload_json}=    Evaluate    json.dumps(${payload})    json
#    ${response}=   Make HTTP Request
#    ...            update_note_request
#    ...            ${endpoint}
#    ...            method=PUT
#    ...            requestBody=${payload_json}
#    ...            expectedStatusCode=200
#    ...            requestHeaders=${headers}
#    ...            requestDataType=json
#    ...            responseDataType=json
#    ...            responseVerificationType=none
#
#    ${raw_body}=   Set Variable    ${response.responseBody}
#    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
#    ${updated_note}=     Set Variable    ${body['data']}
#
#    ${updated_title}=        Set Variable    ${updated_note['title']}
#    ${updated_description}=  Set Variable    ${updated_note['description']}
#    ${updated_category}=     Set Variable    ${updated_note['category']}
#
#    Update Note Metadata File    ${note_id}    ${updated_title}    ${updated_description}    ${updated_category}
#
#Update Note Metadata File
#    [Arguments]    ${note_id}    ${title}    ${description}    ${category}
#    ${new_content}=    Set Variable    ${note_id}|${title}|${description}|${category}
#    Create File    ${NOTE_META_FILE}    ${new_content}
#*** Settings ***
#Library           RESTLibrary
#Library           OperatingSystem
#Library           JSONLibrary
#Library           Collections
#Library           String
#Resource        ../../resources/variables/common_variables.robot
#Resource        update_note_keywords.robot

*** Settings ***
Library           RESTLibrary
Library           OperatingSystem
Library           JSONLibrary
Library           Collections
Library           String
Resource          ../../resources/variables/common_variables.robot
Resource          update_note_keywords.robot

*** Test Cases ***
Update Note via Backend
    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD
    ${note_id}    ${old_title}    ${old_description}    ${old_category}=    update_note_keywords.Read Note Metadata
    ${title}    ${description}    ${category}=    update_note_keywords.Read Random Note Content From JSON
    ${auth_token}=   update_note_keywords.Get Auth Token    ${EMAIL}    ${PASSWORD}
    ${note_url}=     Set Variable    ${BASE_URL}${UPDATE_NOTE_ENDPOINT}/${note_id}
    ${completed}=    update_note_keywords.Get Note Completed Status    ${note_url}    ${auth_token}
    update_note_keywords.Update Note Fields
    ...    ${note_url}
    ...    ${auth_token}
    ...    ${note_id}
    ...    ${title}
    ...    ${description}
    ...    ${category}
    ...    ${completed}
