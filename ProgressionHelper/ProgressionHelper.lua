local frame = CreateFrame("Frame", "ProgressionHelperFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(420, 300)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Show()

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", frame, "TOP", 0, -10)
title:SetText("Progression Helper Checklist")

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetSize(380, 240)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(360, 600)
scrollFrame:SetScrollChild(content)

local checklistItems = {}
local manualOverrides = {}
local waypointReference
local autoMarkEnabled = true
local toggleAutoMarkCheckbox
local currentStepIndex = 1

local waypoints = {
    {mapID = 1449, x = 71.6, y = 76.0, title = "Torwa Pathfinder"},
    {mapID = 1449, x = 71.6, y = 76.0, title = "Torwa Pathfinder"},
    {mapID = 1449, x = 46.4, y = 13.4, title = "Karna Remtravel"},
    {mapID = 1449, x = 44.6, y = 8.2, title = "Linken"},
    {mapID = 1449, x = 43.0, y = 9.6, title = "Muigin"},
    {mapID = 1449, x = 43.6, y = 8.6, title = "Spraggle Frock"},
    {mapID = 1449, x = 43.8, y = 7.2, title = "Williden Marshal"},
    {mapID = 1449, x = 41.8, y = 2.4, title = "J.D. Collie"},
    {mapID = 1419, x = 51.8, y = 35.6, title = "Kum'isha the Collector"},
    {mapID = 1419, x = 51.8, y = 35.6, title = "Kum'isha the Collector"},
    {mapID = 1419, x = 50.6, y = 14.2, title = "Bloodmage Lynnore"},
    {mapID = 1419, x = 50.6, y = 14.2, title = "Bloodmage Drazial"},
    {mapID = 1435, x = 34.2, y = 66.0, title = "Fallen Hero of the Horde"},
    {mapID = 1448, x = 54.2, y = 86.8, title = "Arathandris Silversky"},
    {mapID = 1448, x = 54.2, y = 86.8, title = "Arathandris Silversky"},
    {mapID = 1448, x = 51.2, y = 82.2, title = "Greta Mosshoof"},
    {mapID = 1448, x = 51.2, y = 82.0, title = "Jessir Moonbow"},
    {mapID = 1448, x = 51.2, y = 81.6, title = "Eridan Bluewind"},
    {mapID = 1448, x = 50.8, y = 81.6, title = "Taronn Redfeather"},
    {mapID = 1457, x = 42.0, y = 85.8, title = "Gracina Spiritmight"},
    {mapID = 1457, x = 39.8, y = 42.6, title = "Idriana"},
    {mapID = 1457, x = 34.8, y = 8.8, title = "Arch Druid Fandral Staghelm"},
    {mapID = 1457, x = 31.8, y = 7.0, title = "Jenal"},
    {mapID = 1457, x = 34.8, y = 7.4, title = "Mathrengyl Bearwalker"},
    {mapID = 1457, x = 63.2, y = 23.0, title = "Raedon Duskstriker"},
    {mapID = 1457, x = 58.0, y = 34.6, title = "Alliance Brigadier General"},
    {mapID = 1453, x = 37.8, y = 80.2, title = "Garion Wendell"},
    {mapID = 1453, x = 44.2, y = 73.6, title = "Clavicus Knavingham"},
    {mapID = 1453, x = 48.4, y = 30.6, title = "Royal Factor Bathrilor"},
    {mapID = 1453, x = 52.4, y = 41.8, title = "Ol Emma"},
    {mapID = 1453, x = 64.2, y = 20.8, title = "Brohann Caskbelly"},
    {mapID = 1455, x = 31.2, y = 4.6, title = "Tymor"},
    {mapID = 1455, x = 43.6, y = 31.8, title = "Mistina Steelshield"},
    {mapID = 1455, x = 71.6, y = 16.6, title = "Curator Thorius"},
    {mapID = 1455, x = 75.6, y = 23.6, title = "Laris Geardawdle"},
    {mapID = 1455, x = 73.8, y = 47.8, title = "Bubulo Acerbus"},
}

-- steps array
local steps = {
    {stepText = "Step 1: Start summons to North Un'Goro camp", details = {"Additional Info: Download TomTom for waypoints. Disable auto completion of quests if you have completed some quests that are in the list and mark steps manually."}, checked = false},
    {stepText = "Step 2: Hand in South camp", details = {"NPC: Torwa Pathfinder", "Quest 1: The Bait for Lar'korwi", "Quest 2: The Mighty U'cha"}, checked = false},
    {stepText = "Step 3: Hand in Chasing A Me 01", details = {"NPC: Karna Remtravel", "Quest 1: Chasing A Me 01"}, checked = false},
    {stepText = "Step 4: Hand in It's Dangerous to Go Alone", details = {"NPC: Linken", "Quest 1: It's Dangerous to Go Alone"}, checked = false},
    {stepText = "Step 5: Hand in Haze of Evil and follow-up", details = {"NPC: Muigin", "Quest 1: Haze of Evil", "Quest 2: Bloodpetal Sprouts"}, checked = false},
    {stepText = "Step 6: Hand in both quests to Spraggle Frock", details = {"NPC: Spraggle Frock", "Quest 1: A Little Help From My Friends", "Quest 2: Beware of Pterrordax"}, checked = false},
    {stepText = "Step 7: Hand in Expedition Salvation and Journal", details = {"NPC: Williden Marshal", "Quest 1: Expedition Salvation", "Quest 2: Williden's Journal"}, checked = false},
    {stepText = "Step 8: Hand in Crystals of Power", details = {"NPC: J.D. Collie", "Use Swiftness/Skull/Rocket Boots/Nifty whatever is available", "Quest 1:Crystals of Power"}, checked = false},
    {stepText = "Step 9: Summon to Kum'isha the Collector in Blasted Lands (step doesn't autocomplete)", checked = false},
    {stepText = "Step 10: Hand in quests to Kum'isha the Collector", details = {"NPC: Kum'isha the Collector", "Quest 1: To Serve Kum'isha", "Quest 2: Everything Counts In Large Amounts"}, checked = false},
    {stepText = "Step 11: Hand in quests to Bloodmage Lynnore & Drazial", details = {"NPC: Bloodmage Lynnore, Bloodmage Drazial", "Quest 1: Vulture's Vigor", "Quest 2: The Basilisk's Bite", "Quest 3: A Boar's Vitality"}, checked = false},
    {stepText = "Step 12: Hand in quests to Bloodmage Lynnore & Drazial", details = {"NPC: Bloodmage Lynnore, Bloodmage Drazial", "Quest 4: Snickerfang Jowls", "Quest 5: The Decisive Striker"}, checked = false},
    {stepText = "Step 13: Hand in The Stones That Bind Us and follow-ups", details = {"NPCS: Fallen Hero of the Horde, Corporal Thund Splithoof (close to Fallen Hero), Lockbox ", "Quest 1: The Stones That Bind Us", "Quest 2: Heroes of Old", "Quest 3: Heroes of Old"}, checked = false},
    {stepText = "Step 14: Summon to Arathandris Silversky in Felwood (step doesn't autocomplete)", checked = false},
    {stepText = "Step 15: Hand in Cleansing Felwood", details = {"NPC: Arathandris Silversky", "Quest 1: Cleansing Felwood"}, checked = false},
    {stepText = "Step 16: Hand in A Final Blow", details = {"NPC: Greta Mosshoof", "Quest 1: A Final Blow"}, checked = false},
    {stepText = "Step 17: Hand in The Remains of Trey Lightforge", details = {"NPC: Jessir Moonbow", "Quest 1: The Remains of Trey Lightforge"}, checked = false},
    {stepText = "Step 18: Hand in quests to Eridan Bluewind", details = {"NPC: Eridan Bluewind", "Quest 1: Felbound Ancients", "Quest 2: Further Corruption"}, checked = false},
    {stepText = "Step 19: Hand in Verifying the Corruption", details = {"NPC: Taronn Redfeather", "Quest 1: Verifying the Corruption"}, checked = false},
    {stepText = "Step 20: Portal to Darnassus, Hand in Calm Before the Storm (Upstairs)", details = {"NPC: Gracina Spiritmight", "Quest 1: Calm Before the Storm"}, checked = false},
    {stepText = "Step 21: Hand in Calm Before the Storm (follow-up at Bank)", details = {"NPC: Idriana", "Quest 1: Calm Before the Storm"}, checked = false},
    {stepText = "Step 22: Accept Un'Goro Soil from Arch Druid Fandral Staghelm (top of druid trainer hut, step doesn't autocomplete)", details = {"NPC: Arch Druid Fandral Staghelm"}, checked = false},
    {stepText = "Step 23: Hand in Un'Goro Soil to Jenal (jump directly down) and accept Morrowgrain Research", details = {"NPC: Jenal", "Quest 1: Un'Goro Soil"}, checked = false},
    {stepText = "Step 24: Hand in Morrowgrain Research (middle floor)", details = {"NPC: Mathrengyl Bearwalker", "Quest 1: Morrowgrain Research"}, checked = false},
    {stepText = "Step 25: Hand in Cloths (step doesn't autocomplete)", details = {"NPC: Raedon Duskstriker"}, checked = false},
    {stepText = "Step 26: Hand in BG Quests (step doesn't autocomplete)", details = {"NPC: Alliance Brigadier General"}, checked = false},
    {stepText = "Step 27: Portal to Stormwind, Hand in A Lesson in Literacy (mage only, step doesn't autocomplete)", details = {"NPC: Garion Wendell"}, checked = false},
    {stepText = "Step 28: Hand in Cloths (step doesn't autocomplete)", details = {"NPC: Clavicus Knavingham"}, checked = false},
    {stepText = "Step 29: Accept Good Natured Emma from Royal Factor Bathrilor (step doesn't autocomplete)", details = {"NPC: Royal Factor Bathrilor"}, checked = false},
    {stepText = "Step 30: Hand in A Good Natured Emma", details = {"NPC: Ol Emma", "Quest 1: Good Natured Emma"}, checked = false},
    {stepText = "Step 31: Hand in Into The Temple of Atal'Hakkar", details = {"NPC: Brohann Caskbelly", "Quest 1: Into The Temple of Atal'Hakkar"}, checked = false},
    {stepText = "Step 32: Portal to Ironforge, Hand in Return to Tymor", details = {"NPC: Tymor", "Quest 1: Return to Tymor"}, checked = false},
    {stepText = "Step 33: Hand in Cloths (1/2) (step doesn't autocomplete)", details = {"NPC: Mistina Steelshield"}, checked = false},
    {stepText = "Step 34: Hand in Rise, Obsidion!", details = {"NPC: Curator Thorius", "Quest 1: Rise, Obsidion!"}, checked = false},
    {stepText = "Step 35: Hand in A Little Slime Goes a Long Way", details = {"NPC: Laris Geardawdle", "Quest 1: A Little Slime Goes a Long Way"}, checked = false},
    {stepText = "Step 36: Hand in Cloths (2/2) (step doesn't autocomplete)", details = {"NPC: Bubulo Acerbus"}, checked = false},
    {stepText = "Step 37: Sort Inventory, consumes, don't forget BRD note, check step to close UI and TomTom and kekbye", checked = false},
}

-- quest dictionary
local questDictionary = {
    ["The Mighty U'cha"] = 4301,
    ["The Bait for Lar'korwi"] = 4292,
    ["Chasing A Me 01"] = 4245,
    ["It's Dangerous to Go Alone"] = 3962,
    ["Haze of Evil"] = 4143,
    ["Bloodpetal Sprouts"] = 4144,
    ["A Little Help From My Friends"] = 4491,
    ["Beware of Pterrordax"] = 4501,
    ["Expedition Salvation"] = 3881,
    ["Williden's Journal"] = 3884,
    ["Crystals of Power"] = 4284,
    ["To Serve Kum'isha"] = 2521,
    ["Everything Counts In Large Amounts"] = 3501,
    ["Vulture's Vigor"] = 2603,
    ["The Basilisk's Bite"] = 2601,
    ["A Boar's Vitality"] = 2583,
    ["Snickerfang Jowls"] = 2581,
    ["The Decisive Striker"] = 2585,
    ["The Stones That Bind Us"] = 2681,
    ["Heroes of Old"] = 2702,
    ["Heroes of Old"] = 2701,
    ["Cleansing Felwood"] = 4101,
    ["A Final Blow"] = 5242,
    ["The Remains of Trey Lightforge"] = 5385,
    ["Felbound Ancients"] = 4441,
    ["Further Corruption"] = 4906,
    ["Verifying the Corruption"] = 5156,
    ["Calm Before the Storm"] = 4508,
    ["Calm Before the Storm"] = 4510,
    ["Un'Goro Soil"] = 3764,
    ["Morrowgrain Research"] = 3781,
    ["Good Natured Emma"] = 5048,
    ["Into The Temple of Atal'Hakkar"] = 1475,
    ["Return to Tymor"] = 3461,
    ["Rise, Obsidion!"] = 3566,
    ["A Little Slime Goes a Long Way"] = 4513,
}

local function HandleFinalStepCompletion()
    if frame then
        frame:Hide()
    end
end

-- Function to create a quest checkbox
local function CreateQuestCheckbox(questID)
    local taskCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    taskCheckbox:SetChecked(C_QuestLog.IsQuestFlaggedCompleted(questID))
    taskCheckbox.questID = questID

    local function UpdateQuestCheckbox()
        if not autoMarkEnabled then return end
        if manualOverrides[taskCheckbox.questID] then return end
        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
            taskCheckbox:SetChecked(true)
        else
            taskCheckbox:SetChecked(false)
        end
    end

    taskCheckbox:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 5 then
            UpdateQuestCheckbox()
            self.elapsed = 0
        end
    end)

    return taskCheckbox
end

-- Load saved state if available
local function LoadSavedState()
    if ProgressionHelperSavedState then
        for stepIndex, state in pairs(ProgressionHelperSavedState) do
            if checklistItems[stepIndex] then
                checklistItems[stepIndex].checkbox:SetChecked(state)
                manualOverrides[stepIndex] = state
                if state then
                    currentStepIndex = math.max(currentStepIndex, stepIndex + 1)
                end
            end
        end
        autoMarkEnabled = ProgressionHelperSavedState.autoMarkEnabled or true
        if toggleAutoMarkCheckbox then
            toggleAutoMarkCheckbox:SetChecked(autoMarkEnabled)
        end
    end
end

-- Save the current state
local function SaveCurrentState()
    ProgressionHelperSavedState = { autoMarkEnabled = autoMarkEnabled }
    for stepIndex, item in ipairs(checklistItems) do
        ProgressionHelperSavedState[stepIndex] = item.checkbox:GetChecked()
    end
end

-- Function to check if TomTom is available
local function IsTomTomAvailable()
    return TomTom ~= nil
end

-- Function to set a waypoint using TomTom
local function SetTomTomWaypoint(mapID, x, y, title)
    if IsTomTomAvailable() then
        if waypointReference then
            TomTom:RemoveWaypoint(waypointReference)
        end
        waypointReference = TomTom:AddWaypoint(mapID, x / 100, y / 100, {
            title = title,
            persistent = nil,
            minimap = true,
            world = true
        })
    else
        print("TomTom not available. Please install TomTom to use the waypoint feature.")
    end
end

-- Function to remove the waypoint
local function RemoveTomTomWaypoint()
    if waypointReference and IsTomTomAvailable() then
        TomTom:RemoveWaypoint(waypointReference)
        waypointReference = nil
    end
end

-- Function to check if a step is completed
local function IsStepCompleted(stepIndex)
    local checkbox = checklistItems[stepIndex].checkbox
    return checkbox and checkbox:GetChecked()
end

-- Function to update the waypoint and arrow display based on the current step
local function UpdateWaypoint()
    RemoveTomTomWaypoint()
    for stepIndex = 1, #steps do 
        if not IsStepCompleted(stepIndex) then
            local waypoint = waypoints[stepIndex]
            if waypoint then
                SetTomTomWaypoint(waypoint.mapID, waypoint.x, waypoint.y, waypoint.title)
            end
            break
        end
    end
end

-- Function to check if all tasks are completed for a step and mark the main checkbox
local function CheckAllTasksCompleted(mainCheckbox, taskCheckboxes, stepIndex)
    if #taskCheckboxes == 0 then return end
    if manualOverrides[stepIndex] then return end

    local allCompleted = true
    for _, taskCheckbox in ipairs(taskCheckboxes) do
        if not taskCheckbox:GetChecked() then
            allCompleted = false
            break
        end
    end

    mainCheckbox:SetChecked(allCompleted)
    if allCompleted then
        manualOverrides[stepIndex] = true
    end
end

-- Function to update the checklist from the current step
local function UpdateChecklistFromStep()
    currentStepIndex = 1
    while currentStepIndex <= #checklistItems and IsStepCompleted(currentStepIndex) do
        currentStepIndex = currentStepIndex + 1
    end

    if currentStepIndex > #checklistItems then
        HandleFinalStepCompletion() 
    end

    UpdateWaypoint()
end

-- Function to create a checklist item with optional bullet list for details
local function CreateChecklistItem(parent, stepText, details, yPosition, checked, stepIndex)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 10, yPosition)
    checkbox:SetChecked(checked)

    local stepFont = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    stepFont:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    stepFont:SetWidth(340)
    stepFont:SetJustifyH("LEFT")
    stepFont:SetText(stepText)

    local taskCheckboxes = {}
    local lastDetailFont = stepFont
    if details then
        for i, detail in ipairs(details) do
            local yOffset = -i * 5

            local bulletFont = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            bulletFont:SetPoint("TOPLEFT", lastDetailFont, "BOTTOMLEFT", 0, yOffset)
            bulletFont:SetWidth(320)
            bulletFont:SetJustifyH("LEFT")
            bulletFont:SetText("• " .. detail)

            for questName, questID in pairs(questDictionary) do
                if detail:find(questName) then
                    local taskCheckbox = CreateQuestCheckbox(questID)
                    taskCheckbox:SetPoint("LEFT", bulletFont, "LEFT", -30, 0)
                    table.insert(taskCheckboxes, taskCheckbox)
                    break
                end
            end

            lastDetailFont = bulletFont
        end
    end

    local stepHeight = stepFont:GetStringHeight()
    local totalDetailHeight = 0
    if details then
        for _, detail in ipairs(details) do
            local bulletFont = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            bulletFont:SetText(detail)
            totalDetailHeight = totalDetailHeight + bulletFont:GetStringHeight() + 20
        end
    end
    local totalHeight = stepHeight + totalDetailHeight + 10
    parent:SetHeight(totalHeight)

    local ticker
    if autoMarkEnabled then
        ticker = C_Timer.NewTicker(1, function()
            if autoMarkEnabled then
                CheckAllTasksCompleted(checkbox, taskCheckboxes, stepIndex)
            end
        end)
    end

    checkbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        manualOverrides[stepIndex] = isChecked
        UpdateChecklistFromStep()
        UpdateWaypoint()

        if not autoMarkEnabled and ticker then
            ticker:Cancel()
        end
    end)

    return checkbox, totalHeight, taskCheckboxes
end

currentYPosition = -10
toggleAutoMarkCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
toggleAutoMarkCheckbox:SetPoint("TOPLEFT", content, "TOPLEFT", 10, currentYPosition)
toggleAutoMarkCheckbox:SetChecked(autoMarkEnabled)
toggleAutoMarkCheckbox.text = toggleAutoMarkCheckbox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
toggleAutoMarkCheckbox.text:SetPoint("LEFT", toggleAutoMarkCheckbox, "RIGHT", 0, 1)
toggleAutoMarkCheckbox.text:SetText("Enable automatic quest completion.")

toggleAutoMarkCheckbox:SetScript("OnClick", function(self)
    autoMarkEnabled = self:GetChecked()
    if not autoMarkEnabled then
        for i, item in ipairs(checklistItems) do
            item.checkbox:SetChecked(false)
            manualOverrides[i] = false
            for _, taskCheckbox in ipairs(item.taskCheckboxes or {}) do
                taskCheckbox:SetChecked(false)
            end
            if item.ticker then
                item.ticker:Cancel()
            end
        end
    else
        for i, item in ipairs(checklistItems) do
            if IsStepCompleted(i) then
                UpdateChecklistFromStep(i)
            end
        end
    end
    print("Auto completion of quests is now " .. (autoMarkEnabled and "enabled" or "disabled") .. ".")
end)

currentYPosition = currentYPosition - 30 
for i, step in ipairs(steps) do
    local checkbox, totalHeight, taskCheckboxes = CreateChecklistItem(content, step.stepText, step.details, currentYPosition, step.checked, i)
    table.insert(checklistItems, {checkbox = checkbox, taskCheckboxes = taskCheckboxes})
    currentYPosition = currentYPosition - totalHeight - 10
end

C_Timer.After(1, function()
    if autoMarkEnabled and not IsStepCompleted(1) then
        checklistItems[1].checkbox:SetChecked(true)
        manualOverrides[1] = true
        UpdateChecklistFromStep()
        print("Step 1 automatically marked as complete")
    end
end)

C_Timer.NewTicker(1, function()
    if autoMarkEnabled then
        for i, item in ipairs(checklistItems) do
            CheckAllTasksCompleted(item.checkbox, item.taskCheckboxes or {}, i)
        end
    end
end)

-- Regularly update waypoint based on current step completion
C_Timer.NewTicker(1, function()
    UpdateWaypoint()
end)

SLASH_PROGRESSIONHELPER1 = "/ph"
SLASH_PROGRESSIONHELPER2 = "/progressionhelper"
SlashCmdList["PROGRESSIONHELPER"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ProgressionHelper" then
        print("Progression Helper loaded. Type /ph or /progressionhelper to toggle the UI.")
        LoadSavedState()
    elseif event == "PLAYER_LOGOUT" then
        SaveCurrentState()
    end
end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")