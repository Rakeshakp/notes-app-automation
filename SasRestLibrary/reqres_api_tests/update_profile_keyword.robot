*** Settings ***
Library    RESTLibrary
Library    String
Library    Collections
Library    OperatingSystem
Resource     ../../resources/variables/common_variables.robot
#
##*** Variables ***
##${BASE_URL}                    https://practice.expandtesting.com/notes/api
##${LOGIN_ENDPOINT}              /users/login
##${UPDATE_PROFILE_ENDPOINT}     /users/profile
##${EMAIL}                       rakeshkp668@gmail.com
##${PASSWORD}                    Rakesh@123
#
#
##*** Keywords ***
##Authenticate And Get Token
##    ${EMAIL}=        Get Environment Variable    EMAIL
##    ${PASSWORD}=     Get Environment Variable    PASSWORD
##    ${headers}=    Create Dictionary
##    ...    Content-Type=application/x-www-form-urlencoded
##    ...    Accept=application/json
##    ${body}=       Set Variable    email=${EMAIL}&password=${PASSWORD}
##
##    ${response}=    Make HTTP Request
##    ...    requestId=login
##    ...    url=${BASE_URL}${LOGIN_ENDPOINT}
##    ...    method=POST
##    ...    requestHeaders=${headers}
##    ...    requestBody=${body}
##    ...    responseVerificationType=none
##
##    ${status}=    Set Variable    ${response.responseStatusCode}
##    Run Keyword If    ${status} != 200    Fail     Login failed with status code ${status}
##
##    ${body}=    Evaluate    json.loads("""${response.responseBody}""")    json
##    ${data}=    Get From Dictionary    ${body}    data
##    ${token}=   Get From Dictionary    ${data}    token
##    RETURN    ${token}

*** Keywords ***
Update Profile And Return Values
    [Arguments]    ${token}    ${name}    ${phone}    ${company}

    ${headers}=    Create Dictionary
    ...    Accept=application/json
    ...    Content-Type=application/json
    ...    x-auth-token=${token}

    ${payload}=    Create Dictionary
    ...    name=${name}
    ...    phone=${phone}
    ...    company=${company}
    ${body}=       Evaluate    json.dumps(${payload})    json

    ${endpoint}=   Set Variable    ${BASE_URL}${UPDATE_PROFILE_ENDPOINT}
    ${response}=   Make HTTP Request
    ...    requestId=update_profile
    ...    url=${endpoint}
    ...    method=PATCH
    ...    requestHeaders=${headers}
    ...    requestBody=${body}
    ...    responseVerificationType=none

    ${status}=     Set Variable    ${response.responseStatusCode}
    Run Keyword If    ${status} != 200    Fail     Profile update failed with status code ${status}

    ${body}=       Evaluate    json.loads("""${response.responseBody}""")    json
    ${data}=       Get From Dictionary    ${body}    data
    ${updated_name}=     Get From Dictionary    ${data}    name
    ${updated_phone}=    Get From Dictionary    ${data}    phone
    ${updated_company}=  Get From Dictionary    ${data}    company

    Log To Console     API Response → Name=${updated_name}, Phone=${updated_phone}, Company=${updated_company}
    RETURN    ${updated_name}    ${updated_phone}    ${updated_company}


#Authenticate And Get Token
#    ${EMAIL}=        Get Environment Variable    EMAIL
#    ${PASSWORD}=     Get Environment Variable    PASSWORD
#    ${headers}=    Create Dictionary
#    ...    Content-Type=application/x-www-form-urlencoded
#    ...    Accept=application/json
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
#
#Login via UI and Logout via API
