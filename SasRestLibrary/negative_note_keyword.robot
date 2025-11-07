*** Settings ***
Library    RESTLibrary
Library    Collections
Library    String
Library    BuiltIn
Resource       ../../Resources/variables/common_variables.robot
Resource    miss_title.robot

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
*** Keywords ***
Create Invalid Note With Missing Description
    [Arguments]    ${token}

    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Content-Type=application/x-www-form-urlencoded
    ...    x-auth-token=${token}
    ${payload}=    Set Variable    title=Invalid Title&description=&category=General
    ${url}=        Set Variable    ${BASE_URL}${CREATE_NOTE_ENDPOINT}

    Make HTTP Request
    ...    requestId=create_note
    ...    url=${url}
    ...    method=POST
    ...    requestHeaders=${headers}
    ...    requestBody=${payload}
    ...    responseVerificationType=none

    #  Validate status code
    ${status}=    Execute RC    <<<rc, create_note, status>>
    Should Be Equal As Integers    ${status}    400

    #  Extract error message using RC
    ${error_message}=    Execute RC    <<<rc, create_note, body, $.message>>
    Log To Console     Note creation failed as expected → ${error_message}
