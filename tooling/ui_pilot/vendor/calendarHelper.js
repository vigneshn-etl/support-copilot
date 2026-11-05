// Vendored from s5-stratos/qa-automation@693bc2490366 tests/utils/calendarHelper.js — do not edit here; re-copy on upstream changes.
// Clients whose DayPicker caption renders <select name="year"> / <select name="month">
// dropdowns instead of plain text (Torrid, Express). Their calendars default to 2015,
// so for these clients we jump the year directly via the dropdown instead of clicking
// prev/next dozens of times. All other clients are untouched.
const DROPDOWN_YEAR_CLIENTS = new Set(['trd', 'exp']);

/**
 * calendarHelper.js
 * Selects a fiscal week range (start + optional end) in the DayPicker calendar.
 *
 * @param {import('playwright').Locator} scope  - The datepicker container locator
 * @param {import('playwright').Page}    page   - The Playwright page (needed for waitForTimeout)
 * @param {string} startFiscal                  - e.g. "2024-W26" or "2024_W26"
 * @param {string} [endFiscal]                  - e.g. "2024-W30" (optional — omit for single week)
 * @param {string} [clientCode]                 - Resolved client code (e.g. "trd", "exp") — enables year-dropdown fast path
 */
async function selectFiscalWeek(scope, page, startFiscal, endFiscal, clientCode) {
    console.log(`--- Selecting Start Week: ${startFiscal} ---`);
    await navigateAndClick(scope, page, startFiscal, clientCode);

    if (endFiscal) {
        console.log(`--- Selecting End Week: ${endFiscal} ---`);
        await navigateAndClick(scope, page, endFiscal, clientCode);
    }

    const confirmBtn = scope.locator('.fa-check, .DayPicker-Confirm').first();
    if (await confirmBtn.isVisible()) {
        await confirmBtn.click();
        console.log('Range confirmed with checkmark.');
    }
}

/**
 * Internal: jumps the DayPicker caption's year <select> straight to targetYearInt.
 * No-ops if the dropdown isn't present (other clients) or already on the target year.
 *
 * @param {import('playwright').Locator} scope
 * @param {number} targetYearInt
 */
async function jumpToYearViaDropdown(scope, targetYearInt) {
    const yearSelect = scope.locator('.DayPicker-Caption select[name="year"]').first();
    if (!(await yearSelect.count())) return;

    const currentValue = await yearSelect.inputValue();
    if (parseInt(currentValue) === targetYearInt) return;

    const optionValues = await yearSelect.locator('option').evaluateAll(opts => opts.map(o => o.value));
    if (!optionValues.includes(String(targetYearInt))) return;

    console.log(`  → dropdown nav: jumping year select from ${currentValue} to ${targetYearInt}`);
    await yearSelect.selectOption(String(targetYearInt));
}

/**
 * Internal: reads the left-pane caption's header text and current year.
 *
 * Once a caption `<select>` has been driven via `.selectOption()` (the dropdown-nav
 * fast path), Chromium's `innerText` on the containing `.DayPicker-Caption` starts
 * returning every `<option>` label concatenated instead of just the selected one —
 * so `headerText.match(/\d{4}/)` would always match "2015" (the first option), no
 * matter which year is actually selected. Reading the year select's own value
 * sidesteps that. Clients without the dropdown (no `select[name="year"]`) are
 * unaffected and keep parsing the year out of the plain caption text.
 *
 * @param {import('playwright').Locator} scope
 */
async function readCalendarCaption(scope) {
    const caption = scope.locator('.DayPicker-Caption').first();
    const headerText = await caption.innerText();

    const yearSelect = caption.locator('select[name="year"]');
    if (await yearSelect.count()) {
        return { headerText, currentYear: parseInt(await yearSelect.inputValue()) };
    }

    const yearMatch = headerText.match(/\d{4}/);
    if (!yearMatch) throw new Error(`Could not find year in calendar header: "${headerText}"`);
    return { headerText, currentYear: parseInt(yearMatch[0]) };
}

/**
 * Internal: Navigates the fiscal calendar and clicks the target week row.
 *
 * @param {import('playwright').Locator} scope
 * @param {import('playwright').Page}    page
 * @param {string} fiscalString  - e.g. "2024-W26"
 * @param {string} [clientCode]  - Resolved client code — enables year-dropdown fast path for Torrid/Express
 */
async function navigateAndClick(scope, page, fiscalString, clientCode) {
    if (!fiscalString) {
        throw new Error(`navigateAndClick received an invalid fiscalString: "${fiscalString}".`);
    }

    // Parse "2024-W26" or "2024_W26"
    const separator = fiscalString.includes('-') ? '-' : '_';
    const [targetYear, targetWeek] = fiscalString.split(separator);
    const targetWeekNum = parseInt(targetWeek.replace('W', ''));
    const targetYearInt = parseInt(targetYear);

    if (!targetYear || !targetWeek || isNaN(targetWeekNum) || isNaN(targetYearInt)) {
        throw new Error(`Could not parse fiscalString: "${fiscalString}". Expected format: "2024-W26".`);
    }

    // Two-pane DayPicker: one prev button (far left), one next button (far right)
    const prevButton = scope.locator('.DayPicker-NavButton--prev').first();
    const nextButton = scope.locator('.DayPicker-NavButton--next').last();

    // Fast path (Torrid/Express only): jump straight to the target year via the
    // dropdown so the loop below only needs a handful of prev/next clicks to land
    // on the right month, instead of walking from the calendar's 2015 default.
    if (DROPDOWN_YEAR_CLIENTS.has(clientCode)) {
        await jumpToYearViaDropdown(scope, targetYearInt);
        await page.waitForTimeout(300);
    }

    let safetyNet = 0;

    while (safetyNet < 48) {
        const { headerText, currentYear } = await readCalendarCaption(scope);

        const allWeekTexts = await scope.locator('.DayPicker-WeekNumber').allInnerTexts();
        const validWeeks   = allWeekTexts.filter(w => /^W\d+$/.test(w));

        const firstNum   = validWeeks.length > 0 ? parseInt(validWeeks[0].replace('W', '')) : 0;
        const lastNum    = validWeeks.length > 0 ? parseInt(validWeeks[validWeeks.length - 1].replace('W', '')) : 0;
        const isWrapping = validWeeks.length > 0 && lastNum < firstNum;

        // A fiscal year occasionally has 53 weeks. When the display wraps AND firstNum > 52,
        // the high-numbered week (W53) is the overflow tail of the PREVIOUS fiscal year shown
        // in the new year's calendar page — so the visible low weeks (W01..lastNum) belong to
        // currentYear (the left-pane caption year).
        // When firstNum <= 52, it is a normal year-end boundary: high weeks belong to
        // currentYear, low weeks belong to currentYear+1.
        const isOverflowWeek = isWrapping && firstNum > 52;

        // Check if target week is visible in any pane.
        const weekLocator = scope.locator('.DayPicker-WeekNumber', { hasText: targetWeek });
        if (await weekLocator.first().isVisible()) {
            const effectiveYear = (isWrapping && targetWeekNum <= lastNum)
                ? (isOverflowWeek ? currentYear : currentYear + 1)
                : currentYear;

            if (effectiveYear === targetYearInt) {
                await weekLocator.first()
                    .locator('xpath=..')
                    .locator('.DayPicker-Day:not(.DayPicker-Day--outside)')
                    .first()
                    .click();
                console.log(`✅ Selected ${targetWeek} in "${headerText}" (effectiveYear=${effectiveYear})`);
                return;
            }
        }

        // Navigate in the right direction
        if (currentYear > targetYearInt) {
            await prevButton.click();
        } else if (currentYear < targetYearInt) {
            console.log(`  → year ${currentYear} < ${targetYearInt}, clicking NEXT`);
            await nextButton.click();
        } else if (validWeeks.length > 0) {
            // Same year. When wrapping with an overflow W53, low weeks (W01+) belong to
            // currentYear - target beyond lastNum means go NEXT. For a normal year-end
            // boundary (firstNum <= 52) the low weeks belong to currentYear+1, so any
            // target that is currentYear must lie earlier in the year → always go PREV.
            const goNext = isWrapping
                ? (isOverflowWeek && targetWeekNum > lastNum)
                : targetWeekNum > lastNum;

            console.log(`  → weeks ${validWeeks[0]}..${validWeeks[validWeeks.length - 1]}, wrap=${isWrapping}, target W${targetWeekNum}, clicking ${goNext ? 'NEXT' : 'PREV'}`);
            if (goNext) {
                await nextButton.click();
            } else {
                await prevButton.click();
            }
        } else {
            console.log(`  → no valid weeks found, clicking NEXT (fallback)`);
            await nextButton.click();
        }

        await page.waitForTimeout(300);
        safetyNet++;
    }

    throw new Error(`Failed to find fiscal week "${fiscalString}" after searching ${safetyNet} months.`);
}

module.exports = { selectFiscalWeek };
