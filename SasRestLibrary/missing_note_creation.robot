*** Settings ***
Library    RESTLibrary
Library    Collections
Library    String
Library    BuiltIn
Resource    ../../Resources/variables/common_variables.robot
Resource    negative_note_keyword.robot
Library    OperatingSystem

#*** Variables ***
#${BASE_URL}              https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}        /users/login
#${CREATE_NOTE_ENDPOINT}  /notes
#${EMAIL}                 rakeshkp668@gmail.com
#${PASSWORD}              Rakesh@123

#*** Keywords ***
#Create Invalid Note With Missing Description
#    [Arguments]    ${token}
#
#    ${headers}=    Create Dictionary
#    ...    Accept=application/json
#    ...    Content-Type=application/x-www-form-urlencoded
#    ...    x-auth-token=${token}
#    ${payload}=    Set Variable    title=Invalid Title&description=&category=General
#    ${url}=        Set Variable    ${BASE_URL}${CREATE_NOTE_ENDPOINT}
#
#    ${response}=    Make HTTP Request
#    ...    requestId=create_note
#    ...    url=${url}
#    ...    method=POST
#    ...    requestHeaders=${headers}
#    ...    requestBody=${payload}
#    ...    responseVerificationType=none
#
#    Should Be Equal As Integers    ${response.responseStatusCode}    400

*** Test Cases ***
Create Note With Missing Description Should Fail
    [Tags]    Negative Testcase    API Flow
    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD
    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Content-Type=application/x-www-form-urlencoded

    ${login_payload}=    Set Variable    email=${EMAIL}&password=${PASSWORD}
    ${login_url}=        Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}

    ${login_response}=    Make HTTP Request
    ...    requestId=login
    ...    url=${login_url}
    ...    method=POST
    ...    requestHeaders=${headers}
    ...    requestBody=${login_payload}
    ...    responseVerificationType=none

    ${body}=     Evaluate    json.loads("""${login_response.responseBody}""")    json
    ${token}=    Set Variable    ${body['data']['token']}

    Run Keyword And Expect Error    *Status code verification failed*    Create Invalid Note With Missing Description    ${token}
    Log To Console     Note creation failed as expected due to missing description
