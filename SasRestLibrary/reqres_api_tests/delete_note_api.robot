*** Settings ***
Library           RESTLibrary
Library           OperatingSystem
Library           Collections
Library           String
Library           JSONLibrary
Resource          delete_note_keywords.robot
Resource         ../../resources/variables/common_variables.robot

*** Test Cases ***
Delete Note Created From Metadata
    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD
    Log              Injected EMAIL: ${EMAIL}
    Log              Injected PASSWORD: ${PASSWORD}
    ${login_url}=    Set Variable    ${BASE_URL}${LOGIN_ENDPOINT}
    ${token}=        Get Auth Token    ${login_url}    ${EMAIL}    ${PASSWORD}
    ${note_id}=      Read Note ID From Metadata
    ${delete_url}=   Set Variable    ${BASE_URL}${CREATE_NOTE_ENDPOINT}/${note_id}
    Delete Note By ID    ${delete_url}    ${token}    ${note_id}
