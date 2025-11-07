import os
from playwright.sync_api import sync_playwright
from robot.api.deco import keyword
import json
import subprocess
from dotenv import load_dotenv
import re
from datetime import datetime
import time


class NoteLibrary:
    browser = None
    context = None
    page = None
    pw = None
    NOTE_META_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "data", "note_meta.txt"))

    @keyword("Log Today Notes With Timestamps")
    def log_today_notes_with_timestamps(self):

        page = self.page
        today_ui_format = datetime.now().strftime("%B %#d, %Y")
        # Wait for initial note elements to appear
        page.wait_for_selector(".card-text.mt-auto", timeout=5000)
        page.wait_for_selector(".card-header.fw-bold.text-truncate", timeout=5000)

        # Scroll slowly to load all notes
        for _ in range(5):  # Adjust number of scrolls if needed
            page.keyboard.press("PageDown")
            time.sleep(0.5)  # Pause to allow UI to load more notes

        # Locate all timestamp elements that match today's date
        timestamp_elements = page.locator(f".card-text.mt-auto >> text={today_ui_format}")
        count = timestamp_elements.count()

        if count == 0:
            print(f" No notes found for today ({today_ui_format})")
            return

        print(f" Found {count} notes created today ({today_ui_format}):")

        for i in range(count):
            timestamp_element = timestamp_elements.nth(i)
            timestamp = timestamp_element.text_content().strip()

            # Traverse up to the note card container
            note_card = timestamp_element.locator("xpath=ancestor::div[contains(@class,'card')]")
            title_element = note_card.locator(".card-header.fw-bold.text-truncate")
            title = title_element

    @keyword("Launch Note App")
    def launch_note_app(self):
        NoteLibrary.pw = sync_playwright().start()
        NoteLibrary.browser = NoteLibrary.pw.chromium.launch(headless=False, args=["--start-maximized"])
        NoteLibrary.context = NoteLibrary.browser.new_context(no_viewport=True)
        NoteLibrary.page = NoteLibrary.context.new_page()
        NoteLibrary.page.goto("https://practice.expandtesting.com/notes/app", timeout=40000)
        NoteLibrary.page.wait_for_load_state("domcontentloaded")
        # NoteLibrary.page.wait_for_timeout(2000)

    @keyword("Close Browser")
    def close_browser(self):
        try:
            if NoteLibrary.page: NoteLibrary.page.close()
            if NoteLibrary.context: NoteLibrary.context.close()
            if NoteLibrary.browser: NoteLibrary.browser.close()
            if NoteLibrary.pw: NoteLibrary.pw.stop()
        except Exception as e:
            print(f"Browser already closed or Playwright stopped: {e}")

    @keyword("Get Doppler Secrets")
    def fetch_doppler_secrets(self):
        load_dotenv()
        token = os.getenv("DOPPLER_TOKEN")
        if not token:
            raise ValueError("DOPPLER_TOKEN is not set")

        result = subprocess.run([
            "curl", "-s",
            "-H", f"Authorization: Bearer {token}",
            "https://api.doppler.com/v3/configs/config/secrets/download?format=json"
        ], capture_output=True, text=True)

        if result.returncode != 0 or not result.stdout:
            raise RuntimeError("Failed to fetch secrets from Doppler")

        try:
            secrets = json.loads(result.stdout)
            print(" Doppler secrets fetched:", secrets)
            return secrets
        except json.JSONDecodeError:
            raise ValueError("Invalid JSON response from Doppler")

    @keyword("Login To Note App")
    def login_to_note_app(self):
        secrets = self.fetch_doppler_secrets()
        username = secrets.get("EMAIL")
        password = secrets.get("PASSWORD")

        if not username or not password:
            raise ValueError("EMAIL or PASSWORD not found in Doppler secrets")

        page = NoteLibrary.page
        login_button = page.locator(".btn.btn-primary.btn-lg.px-4.me-md-2")

        login_button.wait_for(state="visible", timeout=10000)
        login_button.scroll_into_view_if_needed()
        page.wait_for_timeout(2000)
        login_button.click()

        page.locator("#email").fill(username)
        page.locator("#password").fill(password)
        submit_login = page.locator("xpath=//button[normalize-space()='Login']")
        submit_login.wait_for(state="visible", timeout=5000)
        submit_login.click()
        page.wait_for_timeout(3000)

    @keyword("Create Note")
    def create_note(self, title, description, category):
        page = NoteLibrary.page
        page.locator(".btn.btn-primary.mt-3.mt-lg-0").click()
        page.locator("#title").fill(title)
        page.locator("#description").fill(description)
        page.locator("#category").select_option(category)
        page.locator("button[data-testid='note-submit']").click()
        page.wait_for_timeout(1000)

    @keyword("Verify Note Visible")
    def verify_note_visible(self, title):
        locator = NoteLibrary.page.locator(f"text={title}").first
        locator.wait_for(state="visible", timeout=8000)
        assert locator.is_visible(), f"Note with title '{title}' not visible in UI"

    @keyword("Save Note Metadata")
    def save_note_metadata(self, title, description, category, filepath=None):
        filepath = filepath or NoteLibrary.NOTE_META_FILE
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, "w") as f:
            f.write(f"{title}|{description}|{category}")

    @keyword("Validate Note From Metadata")
    def validate_note_from_metadata(self):
        if not os.path.exists(NoteLibrary.NOTE_META_FILE):
            raise FileNotFoundError("note_meta.txt not found")

        with open(NoteLibrary.NOTE_META_FILE, "r") as f:
            parts = f.read().strip().split("|", maxsplit=3)
            if len(parts) == 4:
                _, title, description, category = parts  #  Skip note_id
            else:
                title, description, category = parts  #  For UI-created notes

        page = NoteLibrary.page
        page.locator("#search-input").fill(title)
        page.locator("#search-btn").click()
        page.wait_for_timeout(2000)

        for _ in range(2):
            page.keyboard.press("PageDown")
            page.wait_for_timeout(500)

        #  Validate note appears
        for value, label in [(title, "Title"), (description, "Description"), (category, "Category")]:
            locator = page.locator(f"text={value}").first
            locator.wait_for(state="visible", timeout=10000)
            assert locator.is_visible(), f"{label} '{value}' is not visible in UI"

        # page.locator("button:has-text('Edit')").click()

    @keyword("Go To Profile Page")
    def go_to_profile_page(self):
        page = NoteLibrary.page
        page.locator(".btn.btn-outline-primary.me-2.mb-2.mb-sm-0").click()
        NoteLibrary.page.goto("https://practice.expandtesting.com/notes/app/profile")
        page.keyboard.press("PageDown")
        page.wait_for_timeout(4000)

    @keyword("Verify Profile Details")
    def verify_profile_details(self, name, phone, company):
        page = self.page
        # page.wait_for_timeout(50000000)

        page.wait_for_selector("input[name='name']", timeout=20000)
        page.wait_for_selector("input[name='phone']", timeout=20000)
        page.wait_for_selector("input[name='company']", timeout=20000)

        name_ui = page.locator("input[name='name']").input_value().strip()
        phone_ui = page.locator("input[name='phone']").input_value().strip()
        company_ui = page.locator("input[name='company']").input_value().strip()

        print(f" UI shows: Name={name_ui}, Phone={phone_ui}, Company={company_ui}")
        assert name_ui == name
        assert phone_ui == phone
        assert company_ui == company

    @keyword("Clear Browser Session")
    def clear_browser_session(self):
        page = NoteLibrary.page
        page.evaluate("() => { localStorage.clear(); sessionStorage.clear(); }")
        page.context.clear_cookies()

    @keyword("Update Note")
    def update(self, title, description, category):
        page = NoteLibrary.page
        page.locator("button:has-text('Edit')").click()
        page.locator("#title").clear()
        page.locator("#title").fill(title)
        page.locator("#description").clear()
        page.locator("#description").fill(description)
        page.locator("#category").select_option(category)
        page.locator("button[data-testid='note-submit']").click()

    @keyword("Update Note to complete status")
    def update_status_of_note(self):
        page = NoteLibrary.page
        page.locator("button:has-text('Edit')").click()
        page.locator("#completed").click()
        page.locator("button[data-testid='note-submit']").click()
        page.wait_for_timeout(5000)
    @keyword("Extract Note Count For Each Category")
    def extract_note_count_for_each_category(self, *categories):
        page = self.page
        category_counts = {}

        for category in categories:
            # Click the category tab using XPath
            page.locator(f"//span[normalize-space()='{category}']").click()
            page.wait_for_selector(".info-text.mt-2", timeout=5000)

            # Extract the summary line
            full_text = page.locator(".info-text.mt-2").text_content().strip()
            print(f" Found UI text for '{category}': {full_text}")

            # Extract the total note count
            match = re.search(r"\d+/(\d+)\s+notes completed", full_text)
            if match:
                total_notes = int(match.group(1))
                print(f" Extracted total notes count for '{category}': {total_notes}")
                category_counts[category] = total_notes
            else:
                raise ValueError(f" Could not extract note count from UI for category: {category}")
        return category_counts
    @keyword("Validate Note Is Not Visible In UI")
    def validate_note_is_not_visible_in_ui(self):
        if not os.path.exists(self.NOTE_META_FILE):
            raise FileNotFoundError("note_meta.txt not found")

        with open(self.NOTE_META_FILE, "r") as f:
            parts = f.read().strip().split("|", maxsplit=3)
            if len(parts) == 4:
                _, title, description, category = parts
            else:
                title, description, category = parts

        page = self.page
        page.locator("#search-input").fill(title)
        page.locator("#search-btn").click()
        page.wait_for_timeout(2000)

        for _ in range(2):
            page.keyboard.press("PageDown")
            page.wait_for_timeout(500)

        # Check for the "no notes found" message
        no_notes_locator = page.locator("text=Couldn't find any notes in all categories").first
        if no_notes_locator.is_visible():
            print(" Note not found in UI — deletion confirmed.")
            return

        # If the message is not visible, double-check that the note title is not present
        note_locator = page.locator(f"text={title}").first
        assert not note_locator.is_visible(), f" Note with title '{title}' is still visible in UI"



