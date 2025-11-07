*** Settings ***
Library    RESTLibrary
Library    Collections
Library    JSONLibrary
Library    OperatingSystem
Library    String
Resource        ../../Resources/variables/common_variables.robot
Resource        create_note_api_keyword.robot

*** Test Cases ***
Create Random Note via Backend and Save Metadata
    ${token}=      create_note_api_keyword.Login And Get Token

    ${note_list}=    Load JSON From File    ${NOTE_CONTENT_FILE}
    ${count}=        Get Length    ${note_list}
    ${index}=        Evaluate    __import__('random').randint(0, ${count} - 1)
    ${note}=         Get From List    ${note_list}    ${index}

    Log              Creating note: ${note['title']} (${note['category']})
    Create Note And Save Metadata
    ...              ${note['title']}
    ...              ${note['description']}
    ...              ${note['category']}
    ...              ${token}

