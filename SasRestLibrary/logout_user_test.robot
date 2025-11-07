*** Settings ***
Library           RESTLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           JSONLibrary
Resource          logout_user_keywords.robot
Resource          ../../resources/variables/common_variables.robot

*** Test Cases ***
Logout User Session
    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD
    Log              Injected EMAIL: ${EMAIL}
    Log              Injected PASSWORD: ${PASSWORD}
    ${login_url}=    Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
    ${token}=         logout_user_keywords.Get Auth Token    ${login_url}    ${EMAIL}    ${PASSWORD}
    ${logout_url}=   Set Variable    ${BASE_URL}${LOGOUT_ENDPOINT}
    Logout User      ${logout_url}    ${token}
