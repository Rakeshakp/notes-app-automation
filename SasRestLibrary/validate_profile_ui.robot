*** Settings ***
Library    OperatingSystem
Library    String
Library    ../../ui/Library/NoteLibrary.py
Library    Collections
Resource   ../../resources/variables/common_variables.robot
Resource   update_profile_keyword.robot

*** Test Cases ***
Validate Updated Profile via UI
    [Tags]    UI Flow    Profile Sync

    ${EMAIL}=        Get Environment Variable    EMAIL
    ${PASSWORD}=     Get Environment Variable    PASSWORD

    Launch Note App
    Login To Note App      ${EMAIL}    ${PASSWORD}
    Go To Profile Page

    Log To Console     🔍 Validating profile details in UI...
    Log To Console     Expected → Name=${UPDATED_NAME}, Phone=${UPDATED_PHONE}, Company=${UPDATED_COMPANY}

    Verify Profile Details    ${UPDATED_NAME}    ${UPDATED_PHONE}    ${UPDATED_COMPANY}

    Close Browser

    Log To Console     ✅ Profile updated via API and verified via UI
    Log To Console     ✅ UI shows: Name=${UPDATED_NAME}, Phone=${UPDATED_PHONE}, Company=${UPDATED_COMPANY}
