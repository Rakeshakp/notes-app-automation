*** Settings ***
Library    RESTLibrary
Library    BuiltIn
Library    String
Library    Collections
Resource          ../../Resources/variables/common_variables.robot

*** Keywords ***
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
#    ...    responseVerificationType=Strict
#    ...    expectedStatusCode=200
#    Log To Console     Unexpected success: ${response.responseBody}
Attempt Login Via API
    [Arguments]    ${email}    ${password}
    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Content-Type=application/x-www-form-urlencoded
    ${body}=       Set Variable    email=${email}&password=${password}
    ${url}=        Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}

    Make HTTP Request
    ...    requestId=login_attempt
    ...    url=${url}
    ...    method=POST
    ...    requestHeaders=${headers}
    ...    requestBody=${body}
    ...    responseVerificationType=Strict
    ...    expectedStatusCode=200

    ${token}=    Execute RC    <<<rc, login_attempt, body, $.token>>
    ${email}=    Execute RC    <<<rc, login_attempt, body, $.user.email>>
    Log To Console     Login Success → Token=${token}, Email=${email}
    RETURN    ${token}
