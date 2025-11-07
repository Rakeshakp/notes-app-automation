*** Settings ***
Library    RESTLibrary
Library    Collections
Library    JSONLibrary

*** Variables ***
${BASE_URL}           https://practice.expandtesting.com/notes/api
${LOGIN_URL}          ${BASE_URL}/users/login
${CREATE_NOTE_URL}    ${BASE_URL}/notes
${EMAIL}              rakeshkp668@gmail.com
${PASSWORD}           Rakesh@123
${TITLE}              adsd
${DESCRIPTION}        adsds
${CATEGORY}           Work

*** Test Cases ***
Test Login Keyword
    ${token}=    Login And Get Token    ${LOGIN_URL}    ${EMAIL}    ${PASSWORD}
    Log    Token: ${token}

*** Keywords ***
Login And Get Token
    [Arguments]    ${url}    ${email}    ${password}
    ${headers}=    Create Dictionary
    ...           Content-Type=application/json
    ...           Accept=application/json
    ${payload}=    Create Dictionary
    ...           email=${email}
    ...           password=${password}
    ${response}=   Make HTTP Request
    ...           login_request
    ...           ${url}
    ...           method=POST
    ...           requestBody=${payload}
    ...           expectedStatusCode=200
    ...           requestDataType=json
    ...           responseVerificationType=Partial
    ...           requestHeaders=${headers}
    ${response_body}=    Evaluate    json.loads("""${response.responseBody}""")    json
    ${token}=    Get From Dictionary    ${response_body['data']}    token
    [Return]     ${token}

Create Note With Swagger Format
    [Arguments]    ${url}    ${title}    ${description}    ${category}    ${token}
    ${headers}=    Create Dictionary
    ...           Content-Type=application/json
    ...           Accept=application/json
    ...           x-auth-token=${token}
    ${payload}=    Create Dictionary
    ...           title=${title}
    ...           description=${description}
    ...           category=${category}
    ${response}=   Make HTTP Request
    ...           swagger_note_request