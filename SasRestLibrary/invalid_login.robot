*** Settings ***
Library    RESTLibrary
Library    BuiltIn
Library    String
Library    Collections
Resource    ../../Resources/variables/common_variables.robot
Resource    invalid_login_keyword.robot

#*** Variables ***
#${BASE_URL}          https://practice.expandtesting.com/notes/api
#${LOGIN_ENDPOINT}    /users/login

#*** Keywords ***
#Attempt Login Via API
#    [Arguments]    ${email}    ${password}
#    ${headers}=    Create Dictionary
#    ...    Accept=application/json
#    ...    Content-Type=application/x-www-form-urlencoded
#    ${body}=       Set Variable    email=${email}&password=${password}
#    ${url}=        Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
#
#    ${response}=    Make HTTP Request
#    ...    requestId=login_attempt
#    ...    url=${url}
#    ...    method=POST
#    ...    requestHeaders=${headers}
#    ...    requestBody=${body}
#    ...    responseVerificationType=none
#
#    Should Be Equal As Integers    ${response.responseStatusCode}    200

*** Test Cases ***
Unregistered User Login Should Fail But Test Should Pass
    [Tags]    negative    expected_failure

    ${random}=     Generate Random String    5    [LETTERS]
    ${email}=      Set Variable    ghost_${random}@example.com
    ${password}=   Set Variable    WrongPass123

    Run Keyword And Expect Error    *Status code verification failed*    Attempt Login Via API    ${email}    ${password}
