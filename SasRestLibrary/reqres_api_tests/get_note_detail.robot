*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    String
Library    Collections
Resource   ../../Resources/variables/common_variables.robot
Resource    get_display_all_notes_keyword.robot

#*** Variables ***
#${BASE_URL}              https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}        /users/login
#${GET_NOTES_ENDPOINT}    /notes
#${EMAIL}                 rakeshkp668@gmail.com
#${PASSWORD}              Rakesh@123

*** Test Cases ***
Extract And Log All Notes
    ${token}=      Authenticate And Get Token
    ${headers}=    Create Dictionary    Accept=application/json    x-auth-token=${token}
    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}

    Log      Sending GET request to fetch all notes
    ${response}=    Make HTTP Request
    ...    requestId=get_all_notes
    ...    url=${endpoint}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${status}=    Set Variable    ${response.responseStatusCode}
    Run Keyword If    ${status} != 200    Fail     GET failed with status code ${status}

    ${body}=    Evaluate    json.loads("""${response.responseBody}""")    json
    ${notes}=   Get From Dictionary    ${body}    data
    ${count}=   Get Length    ${notes}
    Log      Status Code: ${status}
    Log      Total Notes Found: ${count}

    FOR    ${note}    IN    @{notes}
        ${id}=        Get From Dictionary    ${note}    id
        ${title}=     Get From Dictionary    ${note}    title
        ${desc}=      Get From Dictionary    ${note}    description
        ${category}=  Get From Dictionary    ${note}    category
        Log      Note ID: ${id}
        Log     ️ Title: ${title}
        Log      Description: ${desc}
        Log      Category: ${category}
    END

#*** Keywords ***
#Authenticate And Get Token
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
