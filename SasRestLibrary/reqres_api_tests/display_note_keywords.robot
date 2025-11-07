*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    JSONLibrary
Library    Collections
Library    String
Resource   ../../Resources/variables/common_variables.robot

*** Keywords ***
Authenticate And Get Token
    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD
    ${headers}=      Create Dictionary
    ...              Content-Type=application/x-www-form-urlencoded
    ...              Accept=application/json
    ${body}=         Set Variable    email=${EMAIL}&password=${PASSWORD}
    ${response}=     Make HTTP Request
    ...              requestId=login
    ...              url=${BASE_URL}${LOGIN_ENDPOINT}
    ...              method=POST
    ...              requestHeaders=${headers}
    ...              requestBody=${body}
    ...              responseVerificationType=none
    ${status}=       Set Variable    ${response.responseStatusCode}
    Run Keyword If   ${status} != 200    Fail    Login failed with status code ${status}
    ${body}=         Evaluate    json.loads("""${response.responseBody}""")    json
    ${data}=         Get From Dictionary    ${body}    data
    ${token}=        Get From Dictionary    ${data}    token
    RETURN           ${token}

Display First Note Details
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...            Accept=application/json
    ...            x-auth-token=${token}
    ${endpoint}=   Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}
    Log            Sending GET request to fetch all notes
    ${response}=   Make HTTP Request
    ...            requestId=get_all_notes
    ...            url=${endpoint}
    ...            method=GET
    ...            requestHeaders=${headers}
    ...            responseVerificationType=none
    ${status}=     Set Variable    ${response.responseStatusCode}
    Run Keyword If    ${status} != 200    Fail    GET failed with status code ${status}
    ${body}=       Evaluate    json.loads("""${response.responseBody}""")    json
    ${notes}=      Get From Dictionary    ${body}    data
    ${first_note}=    Set Variable    ${notes}[0]
    ${title}=      Get From Dictionary    ${first_note}    title
    ${desc}=       Get From Dictionary    ${first_note}    description
    ${category}=   Get From Dictionary    ${first_note}    category
    Log             Status Code: ${status}
    Log             Title: ${title}
    Log             Description: ${desc}
    Log             Category: ${category}
