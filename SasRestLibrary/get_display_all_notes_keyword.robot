*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    JSONLibrary
Library    Collections
Library    String
Resource   ../../Resources/variables/common_variables.robot


#Get Notes Status
#    ${status}=    Execute RC    <<<rc, get_all_notes, status>>>
#    RETURN    ${status}
*** Keywords ***
Get Parsed Notes List
    ${notes_json}=    Execute RC    <<<rc, get_all_notes, body, $.data>>>
    ${notes}=         Evaluate    json.loads("""${notes_json}""")    json
    RETURN    ${notes}

#Authenticate And Get Token
#    ${EMAIL}=        Get Environment Variable    EMAIL
#    ${PASSWORD}=     Get Environment Variable    PASSWORD
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
