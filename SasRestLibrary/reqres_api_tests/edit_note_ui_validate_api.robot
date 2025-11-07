*** Settings ***
Library           ../../ui/Library/NoteLibrary.py
Library           RESTLibrary
Library           JSONLibrary
Library           Collections
Library           String
Resource          ../../Resources/variables/common_variables.robot
Resource          create_note_api_keyword.robot
Resource          validate_note_keyword.robot
Resource          update_note_keywords.robot
Resource          validate_edit_note_keyword.robot

Suite Setup       Launch Note App

*** Test Cases ***
Edit Note via UI and Validate via API
    [Tags]    Full Flow    UI and API

    # Step 1: Launch and login to UI
    Login To Note App

    # Step 2: Read existing note metadata
    ${note_id}    ${old_title}    ${old_description}    ${old_category}=    update_note_keywords.Read Note Metadata

    # Step 3: Generate new content
    ${new_title}    ${new_description}    ${new_category}=    update_note_keywords.Read Random Note Content From JSON

    # Step 4: Edit note in UI
    Verify Note Visible    ${old_title}
    update Note             ${new_title}    ${new_description}    ${new_category}
    Save Note Metadata      ${note_id}    ${new_title}    ${new_description}    ${new_category}
    Close Browser

    # Step 5: Read updated metadata and validate via API
    ${updated_id}    ${updated_title}    ${updated_description}    ${updated_category}=    Read Note Metadata
    Validate UI Edited Note via API    ${updated_title}    ${updated_description}    ${updated_category}
