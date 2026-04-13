(async () => {
    const delay = (ms) => new Promise(r => setTimeout(r, ms));

    async function waitFor(fn, timeout = 20000) {
        const start = Date.now();
        while (Date.now() - start < timeout) {
            const res = fn();
            if (res) return res;
            await delay(300);
        }
        throw new Error("Timeout");
    }

    async function retry(fn, times = 5) {
        for (let i = 0; i < times; i++) {
            try {
                return await fn();
            } catch (e) {
                console.log("Retry:", i + 1, e.message);
                await delay(1200);
            }
        }
        throw new Error("Gagal setelah retry");
    }

    // =========================
    // 🔥 ANTI-RESET ENGINE CORE
    // =========================
    function createAntiResetLock(selectEl, expectedValue) {
        let locked = true;

        const observer = new MutationObserver(() => {
            if (!locked) return;

            if (selectEl.value !== expectedValue) {
                console.log("⚠️ React reset detected → re-applying:", expectedValue);

                selectEl.value = expectedValue;
                selectEl.dispatchEvent(new Event("input", { bubbles: true }));
                selectEl.dispatchEvent(new Event("change", { bubbles: true }));
            }
        });

        observer.observe(selectEl, {
            attributes: true,
            childList: true,
            subtree: true
        });

        return {
            stop: () => {
                locked = false;
                observer.disconnect();
            }
        };
    }

    async function humanSelect(selectEl, value) {
        return retry(async () => {

            selectEl.scrollIntoView({ block: "center" });
            selectEl.focus();

            await delay(200);

            selectEl.click();

            const option = Array.from(selectEl.options).find(o => o.value === value);
            if (!option) throw new Error("Option tidak ditemukan: " + value);

            selectEl.selectedIndex = option.index;
            selectEl.value = value;

            const lock = createAntiResetLock(selectEl, value);

            // event chain React-safe
            selectEl.dispatchEvent(new Event("mousedown", { bubbles: true }));
            selectEl.dispatchEvent(new Event("input", { bubbles: true }));
            selectEl.dispatchEvent(new Event("change", { bubbles: true }));
            selectEl.dispatchEvent(new Event("blur", { bubbles: true }));

            // tunggu stabil (ANTI RESET CHECK)
            await delay(1200);

            let stableCount = 0;

            for (let i = 0; i < 10; i++) {
                if (selectEl.value === value) stableCount++;
                else stableCount = 0;

                if (stableCount >= 3) break;

                await delay(200);
            }

            lock.stop();

            if (selectEl.value !== value) {
                throw new Error("Value gagal stabil: " + selectEl.value);
            }

            return true;
        });
    }

    // =========================
    // 🔥 MODAL HANDLER
    // =========================
    async function handleAreYouSureModal() {
        return retry(async () => {

            const modal = document.querySelector('div[role="dialog"][data-state="open"]');
            if (!modal) throw new Error("Modal belum muncul");

            const title = modal.querySelector('.modal-title');
            if (!title || !title.innerText.includes("Are you sure")) {
                throw new Error("Bukan modal konfirmasi");
            }

            const btn = Array.from(modal.querySelectorAll("button"))
                .find(b => b.innerText.trim().toLowerCase() === "continue");

            if (!btn) throw new Error("Continue tidak ditemukan");

            btn.scrollIntoView({ block: "center" });
            btn.focus();

            await delay(200);
            btn.click();

            console.log("✅ Confirm modal clicked");
            return true;
        });
    }

    // =========================
    // STEP 1: OPEN EDIT
    // =========================
    console.log("Step 1: Open Birthday edit...");

    const editBtn = await waitFor(() => {
        const containers = document.querySelectorAll('.form-group.settings-text-field-container');
        for (const c of containers) {
            if (c.innerText.includes("Birthday")) {
                return c.querySelector('[data-testid="setting-text-field-edit-btn"]');
            }
        }
    });

    editBtn.click();

    // =========================
    // STEP 2: WAIT MODAL
    // =========================
    console.log("Step 2: Wait modal...");

    await waitFor(() => document.querySelector('#birthdate-dropdown'));

    const dropdown = document.querySelector('#birthdate-dropdown');

    const month = dropdown.querySelector('.month select');
    const day = dropdown.querySelector('.day select');
    const year = dropdown.querySelector('.year select');

    if (!month || !day || !year) {
        throw new Error("Dropdown tidak lengkap");
    }

    // =========================
    // STEP 3: HUMAN SELECTION
    // =========================
    console.log("Step 3: Human select DOB (ANTI-RESET MODE)");

    await humanSelect(month, "4");   // Apr
    await delay(500);

    await humanSelect(day, "15");
    await delay(500);

    await humanSelect(year, "2013");

    await delay(1500);

    // FINAL VALIDATION
    if (month.value !== "4" || day.value !== "15" || year.value !== "2013") {
        throw new Error("DOB final validation gagal");
    }

    // =========================
    // STEP 4: CONTINUE 1
    // =========================
    console.log("Step 4: Continue 1...");

    const continueBtn1 = await waitFor(() => {
        const btn = document.querySelector('.modal-footer .btn-primary-md');
        return btn && !btn.disabled ? btn : null;
    });

    continueBtn1.click();

    // =========================
    // STEP 5: ARE YOU SURE MODAL
    // =========================
    console.log("Step 5: Confirm modal...");

    await handleAreYouSureModal();

    // =========================
    // STEP 6: 2SV HANDLING
    // =========================
    console.log("Step 6: 2SV check...");

    await delay(2000);

    const input = document.querySelector('#two-step-verification-code-input');

    if (input) {
        console.log("2SV detected");

        const PASSWORD = "ISI_PASSWORD_KAMU";

        input.focus();
        input.value = PASSWORD;

        input.dispatchEvent(new Event("input", { bubbles: true }));
        input.dispatchEvent(new Event("change", { bubbles: true }));

        await delay(1000);

        const verifyBtn = await waitFor(() =>
            document.querySelector('button[aria-label="Verify"]')
        );

        verifyBtn.click();

        console.log("2SV submitted");
    } else {
        console.log("No 2SV required");
    }

    console.log("🎉 DONE - DOB update flow completed (ANTI-RESET ACTIVE)");
})();
