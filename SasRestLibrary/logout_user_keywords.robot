*** Settings ***
Library    RESTLibrary
Library    JSONLibrary
Library    Collections
Library    String
Library    OperatingSystem
Resource   ../../resources/variables/common_variables.robot

*** Keywords ***
Get Auth Token
    [Arguments]    ${login_url}    ${email}    ${password}
    ${headers}=    Create Dictionary
    ...            Content-Type=application/x-www-form-urlencoded
    ...            Accept=application/json
    ${payload}=    Set Variable    email=${email}&password=${password}
    ${response}=   Make HTTP Request
    ...            login_request
    ...            ${login_url}
    ...            method=POST
    ...            requestBody=${payload}
    ...            requestHeaders=${headers}
    ...            requestDataType=text
    ...            responseVerificationType=Partial
    ${raw_body}=   Set Variable    ${response.responseBody}
    ${body}=       Evaluate    json.loads("""${raw_body}""")    json
    ${token}=      Get From Dictionary    ${body['data']}    token
    ${token}=      Strip String    ${token}
    RETURN         ${token}
#Logout User
#    [Arguments]    ${logout_url}    ${token}
#    ${token}=      Strip String    ${token}
#    ${headers}=    Create Dictionary
#    ...            Accept=application/json
#    ...            x-auth-token=${token}
#    Log            Sending logout request to: ${logout_url}
#    ${response}=   Make HTTP Request
#    ...            logout_request
#    ...            ${logout_url}
#    ...            method=DELETE
#    ...            requestHeaders=${headers}
#    ...            expectedStatusCode=200
#    ...            responseVerificationType=none
#    Log            Logout successful
*** Keywords ***
Logout User
    [Arguments]    ${logout_url}    ${token}

    ${token}=      Strip String    ${token}
    ${headers}=    Create Dictionary
    ...            Accept=application/json
    ...            x-auth-token=${token}
    Log            Sending logout request to: ${logout_url}
    Make HTTP Request
    ...    requestId=logout_request
    ...    url=${logout_url}
    ...    method=DELETE
    ...    requestHeaders=${headers}
    ...    expectedStatusCode=200
    ...    responseVerificationType=none

    #  Use RC to extract status and message
    ${status}=       Execute RC    <<<rc, logout_request, status>>
    ${message}=      Execute RC    <<<rc, logout_request, body, $.message>>
    Log To Console    Logout Status: ${status}, Message: ${message}


