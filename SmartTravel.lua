-- SmartTravel for 3.3.5a. Managed native action-bar macro.
-- Druid and non-Druid character paths are handled separately.
-- The macro editor has a hard 255-byte limit in 3.3.5a.
local MAX_MACRO_BYTES = 255
local function message(s) DEFAULT_CHAT_FRAME:AddMessage('|cff66ccffSmartTravel:|r '..s) end
local function onGlobalCooldown()
    local start,duration=GetSpellCooldown(61304)
    return start and start>0 and duration and duration>0
        and (start+duration-GetTime())>0.03
end
local MANAGED_HEADER = '# DO NOT EDIT - SmartTravel'
local LEGACY_HEADERS = {
    MANAGED_HEADER,
    '# DO NOT EDIT - Dynamic macro managed by SmartTravel',
    '# DO NOT EDIT - Managed by SmartTravel',
}
-- Recognize legacy /click macros for migration; never generate /click.
local function isManagedMacro(body)
    if not body then return false end
    for _,header in ipairs(LEGACY_HEADERS) do
        if body:find(header,1,true) then return true end
    end
    return body:find('/click SmartTravelButton',1,true) ~= nil
        or body:find('/click SmartDruidTravelButton',1,true) ~= nil
end
local function writeTravelMacro(body,notify)
    if InCombatLockdown() then return false end
    if #body>MAX_MACRO_BYTES then
        notify('Macro exceeds 255 characters ('..#body..'); existing macro preserved.')
        return false
    end
    local accountCount,characterCount=GetNumMacros()
    local accountLimit=MAX_ACCOUNT_MACROS or 36
    local characterLimit=MAX_CHARACTER_MACROS or 18
    local accountIndex,characterIndices
    characterIndices={}
    -- Account macros occupy indices 1..accountLimit; character macros follow.
    for i=1,accountLimit+characterLimit do
        local name,_,old=GetMacroInfo(i)
        if name and isManagedMacro(old) then
            if i<=accountLimit then
                if not accountIndex then accountIndex=i end
            else
                characterIndices[#characterIndices+1]=i
            end
        end
    end
    if accountIndex then
        local name,_,old=GetMacroInfo(accountIndex)
        if name~=' ' or old~=body then EditMacro(accountIndex,' ',1,body,1) end
    else
        if accountCount>=accountLimit then
            notify('Account-wide macro slots full; free one and type /st refresh. Existing character macro preserved.')
            return false
        end
        accountIndex=CreateMacro(' ',1,body,false)
        if not accountIndex or accountIndex==0 then
            notify('Unable to create account-wide travel macro; existing macro preserved.')
            return false
        end
        notify('Created account-wide travel macro. Drag it from /macro onto your action bar.')
    end
    -- Migrate legacy character macros only after the shared macro exists.
    -- Delete from highest index to lowest so shifting slots cannot skip entries.
    if #characterIndices>0 then
        for i=#characterIndices,1,-1 do DeleteMacro(characterIndices[i]) end
        notify('Removed old character SmartTravel macro(s). Reassign the account-wide macro to your action bar once.')
    end
    return true
end
-- Mount speed tiers adapted from the GoGoMount WotLK mount classifications.
-- Original GoGoMount by Tiker (Rulix); only tier metadata is used here.
local mountTier = {[458]=60,[468]=60,[470]=60,[471]=60,[472]=60,[578]=60,[579]=100,[580]=60,[581]=60,[3363]=310,[5784]=60,[6648]=60,[6653]=60,[6654]=60,[6777]=60,[6898]=60,[6899]=60,[8394]=60,[8395]=60,[10789]=60,[10793]=60,[10795]=60,[10796]=60,[10799]=60,[10873]=60,[10969]=60,[13819]=60,[15779]=100,[15780]=60,[15781]=60,[16055]=100,[16056]=100,[16058]=60,[16059]=60,[16060]=60,[16080]=100,[16081]=100,[16082]=100,[16083]=100,[16084]=100,[17229]=100,[17450]=100,[17453]=60,[17454]=60,[17455]=60,[17456]=60,[17458]=60,[17459]=100,[17460]=100,[17461]=100,[17462]=60,[17463]=60,[17464]=60,[17465]=100,[17481]=100,[18363]=60,[18989]=60,[18990]=60,[18991]=100,[18992]=100,[22717]=100,[22718]=100,[22719]=100,[22720]=100,[22721]=100,[22722]=100,[22723]=100,[22724]=100,[23161]=100,[23214]=100,[23219]=100,[23220]=100,[23221]=100,[23222]=100,[23223]=100,[23225]=100,[23227]=100,[23228]=100,[23229]=100,[23238]=100,[23239]=100,[23240]=100,[23241]=100,[23242]=100,[23243]=100,[23246]=100,[23247]=100,[23248]=100,[23249]=100,[23250]=100,[23251]=100,[23252]=100,[23338]=100,[23509]=100,[23510]=100,[24242]=100,[24252]=100,[25953]=100,[26054]=100,[26055]=100,[26056]=100,[26656]=100,[32235]=150,[32239]=150,[32240]=150,[32242]=280,[32243]=150,[32244]=150,[32245]=150,[32246]=280,[32289]=280,[32290]=280,[32292]=280,[32295]=280,[32296]=280,[32297]=280,[32345]=310,[33176]=150,[33182]=280,[33183]=60,[33184]=280,[33630]=60,[33660]=100,[33943]=150,[34406]=60,[34407]=100,[34767]=100,[34769]=60,[34790]=100,[34795]=60,[34896]=100,[34897]=100,[34898]=100,[34899]=100,[35018]=60,[35020]=60,[35022]=60,[35025]=100,[35027]=100,[35028]=100,[35710]=60,[35711]=60,[35712]=100,[35713]=100,[35714]=100,[36702]=100,[37011]=280,[37015]=310,[39315]=100,[39316]=100,[39317]=100,[39318]=100,[39319]=100,[39798]=280,[39800]=280,[39801]=280,[39802]=280,[39803]=280,[40120]=280,[40192]=310,[41252]=100,[41513]=280,[41514]=280,[41515]=280,[41516]=280,[41517]=280,[41518]=280,[42667]=150,[42668]=280,[42673]=150,[42679]=280,[42680]=60,[42681]=60,[42683]=100,[42684]=100,[42776]=60,[42777]=100,[43688]=100,[43810]=280,[43899]=60,[43900]=100,[43927]=280,[44151]=280,[44153]=150,[44221]=150,[44229]=150,[44317]=310,[44744]=310,[46197]=150,[46199]=280,[46628]=100,[47037]=100,[47977]=60,[48025]=280,[48027]=100,[48778]=100,[48954]=100,[49193]=310,[49322]=100,[49378]=60,[49379]=100,[50281]=100,[50869]=60,[51412]=100,[51960]=280,[54726]=280,[54727]=280,[54729]=280,[54753]=100,[55164]=280,[55531]=100,[58615]=310,[58819]=100,[58983]=100,[59567]=280,[59568]=280,[59569]=280,[59570]=280,[59571]=280,[59572]=100,[59573]=100,[59650]=280,[59785]=100,[59788]=100,[59791]=100,[59793]=100,[59797]=100,[59799]=100,[59802]=100,[59804]=100,[59810]=100,[59811]=100,[59961]=280,[59976]=310,[59996]=280,[60002]=280,[60021]=310,[60024]=310,[60025]=280,[60114]=100,[60116]=100,[60118]=100,[60119]=100,[60136]=100,[60140]=100,[60424]=100,[61229]=280,[61230]=280,[61294]=280,[61309]=280,[61425]=100,[61442]=280,[61444]=280,[61446]=280,[61447]=100,[61451]=150,[61465]=100,[61466]=100,[61467]=100,[61469]=100,[61470]=100,[61996]=280,[61997]=280,[62048]=280,[62087]=100,[63232]=100,[63635]=100,[63636]=100,[63637]=100,[63638]=100,[63639]=100,[63640]=100,[63641]=100,[63642]=100,[63643]=100,[63796]=310,[63844]=280,[63956]=310,[63963]=310,[64656]=100,[64657]=60,[64658]=60,[64659]=100,[64927]=310,[64977]=60,[64987]=100,[65439]=310,[65637]=100,[65638]=100,[65639]=100,[65640]=100,[65641]=100,[65642]=100,[65643]=100,[65644]=100,[65645]=100,[65646]=100,[65917]=100,[66087]=280,[66088]=280,[66090]=100,[66091]=100,[66122]=100,[66123]=100,[66124]=100,[66846]=100,[66847]=60,[66906]=100,[66907]=60,[67336]=310,[67466]=100,[68056]=100,[68057]=100,[68187]=100,[68188]=100,[69395]=310,[69820]=60,[69826]=100,[71342]=280,[71810]=310,[72286]=310,[72807]=310,[72808]=310,[73313]=100,[73629]=60,[73630]=100,[74856]=310,[74918]=100,[75596]=280,[75614]=310,[75973]=310,[84751]=100,[87090]=60,[87091]=100,[88331]=310,[88335]=310}
-- Identify the actual mounted companion for an accurate dismount-only tooltip.
local function mountedCompanionName()
    if not IsMounted() then return nil end
    for i=1,(GetNumCompanions('MOUNT') or 0) do
        local _,name,id=GetCompanionInfo('MOUNT',i)
        if name then
            for buff=1,40 do
                local aura=UnitBuff('player',buff)
                if not aura then break end
                if aura==name or (id and aura==GetSpellInfo(id)) then return name end
            end
        end
    end
    return nil
end
-- Per-character Hearthstone modifier; Alt is the default.
SmartTravelDB = SmartTravelDB or {}
local function hearthMod()
    local value=SmartTravelDB.hearthModifier
    if value~='alt' and value~='shift' and value~='ctrl' and value~='none' then return 'alt' end
    return value
end
local function hearthHeld()
    local key=hearthMod()
    return (key=='alt' and IsAltKeyDown())
        or (key=='shift' and IsShiftKeyDown())
        or (key=='ctrl' and IsControlKeyDown())
end
local function travelHeld()
    return (IsAltKeyDown() or IsShiftKeyDown() or IsControlKeyDown()) and not hearthHeld()
end
local function travelCondition()
    local key=hearthMod()
    if key=='none' then return 'alt/shift/ctrl' end
    if key=='alt' then return 'shift/ctrl' end
    if key=='shift' then return 'alt/ctrl' end
    return 'alt/shift'
end
local function assignedMount(key)
    if key==hearthMod() then return nil end
    local id=SmartTravelDB.mountOverrides and SmartTravelDB.mountOverrides[key]
    if not id then return nil end
    for i=1,(GetNumCompanions('MOUNT') or 0) do
        local _,name,spellID=GetCompanionInfo('MOUNT',i)
        if spellID==id then return {name=name,id=id,index=i} end
    end
    return nil
end
local function heldMountOverride()
    -- A Hearthstone modifier takes priority if multiple modifiers are held.
    if hearthHeld() then return nil end
    for _,key in ipairs({'shift','ctrl','alt'}) do
        local down=(key=='shift' and IsShiftKeyDown())
            or (key=='ctrl' and IsControlKeyDown())
            or (key=='alt' and IsAltKeyDown())
        if down then
            local mount=assignedMount(key)
            if mount then return mount end
        end
    end
    return nil
end
local refreshTravel
local settingsFrame
local function showSettings(registerOnly)
    if not settingsFrame then
        -- WotLK 3.3.5a uses InterfaceOptions_AddCategory, not the retail Settings API.
        local f=CreateFrame('Frame','SmartTravelSettingsPanel',UIParent)
        f.name='SmartTravel'
        -- Scrollable content prevents clipping in compact Blizzard/ElvUI panels.
        local scroll=CreateFrame('ScrollFrame','SmartTravelOptionsScroll',f,'UIPanelScrollFrameTemplate')
        scroll:SetPoint('TOPLEFT',f,'TOPLEFT',12,-10)
        scroll:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-30,10)
        local content=CreateFrame('Frame',nil,scroll)
        content:SetHeight(390)
        content:SetWidth(300)
        scroll:SetScrollChild(content)
        local title=content:CreateFontString(nil,'ARTWORK','GameFontNormalLarge')
        title:SetPoint('TOPLEFT',content,'TOPLEFT',8,-8)
        title:SetText('SmartTravel')
        local description=content:CreateFontString(nil,'ARTWORK','GameFontHighlightSmall')
        description:SetPoint('TOPLEFT',content,'TOPLEFT',8,-35)
        description:SetJustifyH('LEFT')
        description:SetText('Choose a Hearthstone modifier and optional mount overrides for this character.')
        local names={alt='Alt',shift='Shift',ctrl='Ctrl',none='None'}
        local labels={}
        local function label(text)
            local t=content:CreateFontString(nil,'OVERLAY','GameFontHighlight')
            t:SetText(text)
            t:SetJustifyH('LEFT')
            labels[#labels+1]=t
            return t
        end
        local hearthLabel=label('Hearthstone modifier')
        local hearth=CreateFrame('Frame','SmartTravelHearthDropdown',content,'UIDropDownMenuTemplate')
        f.hearth=hearth
        local function refreshDropdowns()
            UIDropDownMenu_SetSelectedValue(hearth,hearthMod())
            UIDropDownMenu_SetText(hearth,names[hearthMod()])
            for _,key in ipairs({'shift','ctrl','alt'}) do
                local dd=f.mountDropdowns[key]
                local assigned=assignedMount(key)
                local disabled=(key==hearthMod())
                UIDropDownMenu_SetText(dd,disabled and 'Reserved for Hearthstone'
                    or (assigned and assigned.name or 'Automatic (default)'))
                UIDropDownMenu_SetSelectedValue(dd,assigned and assigned.id or 0)
                if disabled then UIDropDownMenu_DisableDropDown(dd)
                else UIDropDownMenu_EnableDropDown(dd) end
            end
        end
        f.refresh=refreshDropdowns
        UIDropDownMenu_Initialize(hearth,function(self,level)
            for _,key in ipairs({'alt','shift','ctrl','none'}) do
                local info=UIDropDownMenu_CreateInfo()
                info.text=names[key]
                info.checked=(hearthMod()==key)
                info.func=function()
                    if InCombatLockdown() then
                        DEFAULT_CHAT_FRAME:AddMessage('|cff66ccffSmartTravel:|r Change settings after combat.')
                        return
                    end
                    SmartTravelDB.hearthModifier=key
                    -- Clear a mount assignment when that key becomes Hearthstone.
                    if SmartTravelDB.mountOverrides then SmartTravelDB.mountOverrides[key]=nil end
                    refreshDropdowns()
                    if refreshTravel then refreshTravel() end
                end
                UIDropDownMenu_AddButton(info,level)
            end
        end)
        f.mountDropdowns={}
        for row,key in ipairs({'shift','ctrl','alt'}) do
            local mountLabel=label(names[key]..' mount')
            f.mountLabels=f.mountLabels or {}
            f.mountLabels[key]=mountLabel
            local dd=CreateFrame('Frame','SmartTravelMountDropdown'..names[key],content,'UIDropDownMenuTemplate')
            f.mountDropdowns[key]=dd
            UIDropDownMenu_Initialize(dd,function(self,level)
                local options={{id=0,name='Automatic (default)'}}
                local seen={}
                for i=1,(GetNumCompanions('MOUNT') or 0) do
                    local _,name,id=GetCompanionInfo('MOUNT',i)
                    if name and id and not seen[id] then
                        options[#options+1]={id=id,name=name}
                        seen[id]=true
                    end
                end
                table.sort(options,function(a,b)
                    if a.id==0 then return true end
                    if b.id==0 then return false end
                    return a.name<b.name
                end)
                for _,mount in ipairs(options) do
                    local info=UIDropDownMenu_CreateInfo()
                    info.text=mount.name
                    info.value=mount.id
                    info.checked=((SmartTravelDB.mountOverrides or {})[key] or 0)==mount.id
                    info.func=function()
                        if InCombatLockdown() then return end
                        SmartTravelDB.mountOverrides=SmartTravelDB.mountOverrides or {}
                        SmartTravelDB.mountOverrides[key]=mount.id~=0 and mount.id or nil
                        refreshDropdowns()
                        if refreshTravel then refreshTravel() end
                    end
                    UIDropDownMenu_AddButton(info,level)
                end
            end)
        end
        local note=f:CreateFontString(nil,'OVERLAY','GameFontDisableSmall')
        note:SetPoint('TOPLEFT',content,'TOPLEFT',8,-342)
        note:SetJustifyH('LEFT')
        note:SetText('Mount overrides use your learned mounts. Leave Automatic to keep default behavior.')
        -- Dropdown template extends beyond its anchor by ~16 px on each side.
        -- Recompute positions against actual available panel width.
        local function layout()
            local width=math.max(200,f:GetWidth() or 300)
            local height=math.max(120,f:GetHeight() or 400)
            local usable=math.max(185,width-55)
            content:SetWidth(usable)
            scroll:SetVerticalScroll(0)
            description:SetWidth(usable-16)
            local stacked=usable<340
            local dropWidth=stacked and math.max(115,usable-42) or math.min(190,usable-178)
            local left=stacked and 18 or math.max(160,usable-dropWidth-22)
            local firstY=stacked and -94 or -84
            local step=stacked and 65 or 48
            local function place(lbl,dd,row)
                local y=firstY-(row-1)*step
                lbl:ClearAllPoints()
                lbl:SetPoint('TOPLEFT',content,'TOPLEFT',8,y)
                dd:ClearAllPoints()
                dd:SetPoint('TOPLEFT',content,'TOPLEFT',left,stacked and (y-18) or (y+13))
                UIDropDownMenu_SetWidth(dd,dropWidth)
            end
            place(hearthLabel,hearth,1)
            for row,key in ipairs({'shift','ctrl','alt'}) do
                place(f.mountLabels[key],f.mountDropdowns[key],row+1)
            end
            local noteY=firstY-4*step-12
            note:ClearAllPoints()
            note:SetPoint('TOPLEFT',content,'TOPLEFT',8,noteY)
            note:SetWidth(usable-16)
            content:SetHeight(math.max(height-20,-noteY+65))
        end
        f:SetScript('OnSizeChanged',function() layout() end)
        f:SetScript('OnShow',function(self) layout() self.refresh() end)
        layout()
        settingsFrame=f
        InterfaceOptions_AddCategory(f)
    end
    if registerOnly then return end
    settingsFrame.refresh()
    InterfaceOptionsFrame_OpenToCategory(settingsFrame)
    -- Some 3.3.5a clients need a second call to select the addon entry.
    InterfaceOptionsFrame_OpenToCategory(settingsFrame)
end
local function slashSettings(input)
    input=(input or ''):lower():match('^%s*(.-)%s*$')
    if input=='refresh' or input=='setup' then
        if refreshTravel then refreshTravel() end
    else
        showSettings()
    end
end
-- Shared companion mount classification for every class (including Druids/Shamans).
-- Do not depend on the unreliable 3.3.5a companion flags or riding passives.
local sharedTip=CreateFrame('GameTooltip','SmartTravelSharedMountTip',nil,'GameTooltipTemplate')
sharedTip:SetOwner(UIParent,'ANCHOR_NONE')
local function sharedKnown(id)
    local name=GetSpellInfo(id)
    if not name then return false end
    for tab=1,GetNumSpellTabs() do
        local _,_,offset,count=GetSpellTabInfo(tab)
        for i=offset+1,offset+count do
            if GetSpellName(i,BOOKTYPE_SPELL)==name then return true end
        end
    end
    return false
end
local function sharedTooltipSpeed(id)
    sharedTip:ClearLines()
    if not pcall(sharedTip.SetHyperlink,sharedTip,'spell:'..id) then return nil end
    local best
    for j=2,sharedTip:NumLines() do
        local line=_G['SmartTravelSharedMountTipTextLeft'..j]
        local str=line and line:GetText()
        if str then
            local lower=string.lower(str)
            if string.find(lower,'speed',1,true) or string.find(lower,'movement',1,true) then
                for n in string.gmatch(str,'(%d+)%%') do
                    n=tonumber(n)
                    if n==60 or n==100 or n==150 or n==280 or n==310 then
                        best=math.max(best or 0,n)
                    end
                end
            end
        end
    end
    return best
end
local function sharedMountPool(airAllowed,groundOnly)
    local pool,best={},-1
    local fastGround=sharedKnown(33391) or sharedKnown(34091)
    local fastAir=sharedKnown(34091)
    for i=1,(GetNumCompanions('MOUNT') or 0) do
        local _,name,id,icon=GetCompanionInfo('MOUNT',i)
        if name and id then
            local tier=mountTier[id] or sharedTooltipSpeed(id)
            local flyer=tier and tier>=150
            if not (groundOnly and flyer) and not (flyer and not airAllowed) then
                local speed
                if flyer then
                    if tier==310 and fastAir then speed=310
                    elseif tier==310 then speed=280 -- 310% mounts still fly at trained speed
                    elseif tier==280 and not fastAir then speed=150
                    else speed=tier end
                else
                    speed=tier or (fastGround and 100 or 60)
                end
                local rank=flyer and (1000+speed) or speed
                if rank>best then best=rank pool={} end
                if rank==best then pool[#pool+1]={id=id,name=name,index=i,icon=icon,rank=rank} end
            end
        end
    end
    return pool
end
local _, playerClass = UnitClass('player')
if playerClass == 'DRUID' then
local frame = CreateFrame('Frame')
local aquatic = GetSpellInfo(1066) or 'Aquatic Form'
local travel = GetSpellInfo(783) or 'Travel Form'
local flight = GetSpellInfo(33943) or 'Flight Form'
local swift = GetSpellInfo(40120) or 'Swift Flight Form'
local cold = GetSpellInfo(54197) or 'Cold Weather Flying'
local cat = GetSpellInfo(768) or 'Cat Form'
local elapsed = 0
local function known(name)
    for tab=1,GetNumSpellTabs() do
        local _,_,offset,count = GetSpellTabInfo(tab)
        for i=offset+1,offset+count do
            if GetSpellName(i,BOOKTYPE_SPELL)==name then return true end
        end
    end
    return false
end
-- Both form and regular-mount Druids use the same mount detection as other classes.
local chosenMount,chosenFlyingMount=nil,nil
local function groundMountPool() return sharedMountPool(false,true) end
local function chooseGroundMount()
    local pool=groundMountPool()
    if #pool==0 then return nil end
    for _,v in ipairs(pool) do
        if chosenMount and v.id==chosenMount.id then return v end
    end
    return pool[math.random(#pool)]
end
local function chooseFlyingMount()
    local pool=sharedMountPool(true,false)
    local flyers={}
    for _,v in ipairs(pool) do if v.rank>=1000 then flyers[#flyers+1]=v end end
    if #flyers==0 then return nil end
    for _,v in ipairs(flyers) do
        if chosenFlyingMount and v.id==chosenFlyingMount.id then return v end
    end
    chosenFlyingMount=flyers[math.random(#flyers)]
    return chosenFlyingMount
end
-- When riding a companion mount, cast that same mount to toggle it off.
-- Flight Form is not a companion mount and retains its own combat protection.
local function activeCompanionMount()
    return mountedCompanionName()
end
local function update()
    if InCombatLockdown() then return end
    if not (WorldMapFrame and WorldMapFrame:IsShown()) then SetMapToCurrentZone() end
    local continent = GetCurrentMapContinent()
    local eligible = IsFlyableArea() and (known(flight) or known(swift)) and ((continent==3) or
        (continent==4 and known(cold)))
    local hasAquatic, hasTravel, hasCat = known(aquatic), known(travel), known(cat)
    -- Keep a ground mount selected even in flyable zones: a Druid can
    -- know Flight Form without owning any flying companion mounts.
    local pool=groundMountPool()
    local valid=false
    for _,v in ipairs(pool) do
        if chosenMount and v.id==chosenMount.id then valid=true break end
    end
    if not valid then chosenMount=chooseGroundMount() end
    local swimMount = eligible and chooseFlyingMount() or nil
    -- Prefer an owned flying mount in flyable areas; otherwise fall back
    -- to the best learned ground mount instead of Hearthstone.
    local modifierMount = swimMount or chosenMount
    local flying = eligible and (known(swift) and swift or (known(flight) and flight or nil)) or nil
    -- ElvUI reinitializes its action art when EditMacro fires during the GCD.
    -- Defer changes until the swipe finishes; the 0.15s ticker then refreshes.
    if onGlobalCooldown() then return end
    -- While riding on the ground, a press must ONLY dismount. Do not follow
    -- it with a /cast, which could immediately replace the current mount.
    -- Leave airborne Druid flight-form transitions untouched.
    -- Keep combat forms static; only the fallback action changes out of combat.
    local modifier=travelHeld()
    local customMount=heldMountOverride()
    local activeMount=activeCompanionMount()
    local mount=modifierMount
    local action
    if activeMount and flying and IsFlying() then
        action=flying
    elseif activeMount and IsFlying() then
        action=activeMount
    elseif customMount then
        action=customMount.name
    elseif modifier and mount then
        action=mount.name
    elseif IsSwimming() and hasAquatic then
        action=aquatic
    elseif IsIndoors() and hasCat then
        action=cat
    elseif flying then
        action=flying
    elseif hasTravel then
        action=travel
    elseif chosenMount then
        action=chosenMount.name
    else
        action='Hearthstone'
    end
    -- Grounded mount presses only dismount; the tooltip follows the action
    -- that would be selected after dismounting, not the active mount.
    if IsMounted() and not IsFlying() then
        -- Hearthstone is an immediate action, including when it is the fallback.
        -- Only a selected regular mount should require a dismount-only press.
        if hearthHeld() or action=='Hearthstone' then
            writeTravelMacro(table.concat({MANAGED_HEADER,'#showtooltip Hearthstone','/cast [noflying]Hearthstone'},'\n'),message)
        else
            writeTravelMacro(table.concat({MANAGED_HEADER,'#showtooltip '..action,'/dismount [noflying]'},'\n'),message)
        end
        return
    end
    local key=hearthMod()
    local casts={}
    -- Airborne combat is blocked below; keep the active flight form first
    -- so the bare tooltip resolves to Flight Form rather than Travel Form.
    if known(flight) or known(swift) then
        local currentFlight = known(swift) and swift or flight
        for i=1,40 do
            local aura=UnitBuff('player',i)
            if not aura then break end
            if aura==flight or aura==swift then currentFlight=aura break end
        end
        casts[#casts+1]='[flying]'..currentFlight
    end
    if key~='none' then
        local condition=(known(flight) or known(swift)) and '[mod:' or '[noflying,mod:'
        casts[#casts+1]=condition..key..']Hearthstone'
    end
    if hasAquatic then casts[#casts+1]='[combat,swimming]'..aquatic end
    if hasCat then casts[#casts+1]='[combat,indoors]'..cat end
    if hasTravel then casts[#casts+1]='[combat]'..travel end
    -- Regular mount override is available to Druids too, with the same modifier
    -- as every other class; never allow a modifier to dismount in midair.
    if chosenMount then
        casts[#casts+1]='[noflying,mod:'..travelCondition()..']'..chosenMount.name
    end
    casts[#casts+1]=action
    -- Keep normal form and mount actions unchanged when unmounted or airborne.
    local lines={MANAGED_HEADER,'#showtooltip'}
    if activeMount and flying and IsFlying() then
        -- A mount must be dismissed before entering Flight Form. Never do this in combat.
        lines[#lines+1]='/dismount [nocombat,flying]'
    end
    if known(flight) or known(swift) then
        lines[#lines+1]='/stopmacro [combat,flying]'
    end
    lines[#lines+1]='/cast '..table.concat(casts,';')
    local body=table.concat(lines,'\n')
    writeTravelMacro(body,message)
end
for _,ev in ipairs({'PLAYER_ENTERING_WORLD','PLAYER_LEVEL_UP','LEARNED_SPELL_IN_TAB',
    'ZONE_CHANGED','ZONE_CHANGED_NEW_AREA','ZONE_CHANGED_INDOORS','PLAYER_REGEN_ENABLED','UNIT_AURA','UNIT_SPELLCAST_SUCCEEDED','CHARACTER_POINTS_CHANGED','ACTIVE_TALENT_GROUP_CHANGED','MODIFIER_STATE_CHANGED'}) do
    frame:RegisterEvent(ev)
end
frame:SetScript('OnEvent',function(_,event,unit,spell)
    if event=='MODIFIER_STATE_CHANGED' then
        update()
    elseif event=='UNIT_SPELLCAST_SUCCEEDED' then
        if unit=='player' and chosenMount and spell==chosenMount.name and not IsMounted() then
            chosenMount=chooseGroundMount()
            update()
        end
    else update() end
end)
frame:SetScript('OnUpdate',function(_,dt)
    elapsed=elapsed+dt
    if elapsed>=0.15 then elapsed=0 update() end
end)
refreshTravel=update
SLASH_SMARTTRAVEL1='/st'
SlashCmdList.SMARTTRAVEL=slashSettings

else
-- Non-Druid mount selection. 3.3.5a GetCompanionInfo exposes mount type,
-- but not mount speed. Classify speed from the spell tooltip where possible,
-- supplemented by known exceptions and riding-skill-aware scaling.
local frame = CreateFrame('Frame')
local elapsed, selected = 0,nil
local tooltip=CreateFrame('GameTooltip','SmartTravelScanTooltip',nil,'GameTooltipTemplate')
tooltip:SetOwner(UIParent,'ANCHOR_NONE')
local function known(id)
    local spell=GetSpellInfo(id)
    if not spell then return false end
    for tab=1,GetNumSpellTabs() do
        local _,_,offset,count=GetSpellTabInfo(tab)
        for i=offset+1,offset+count do
            if GetSpellName(i,BOOKTYPE_SPELL)==spell then return true end
        end
    end
    return false
end
local function flyable()
    if not IsFlyableArea() or InCombatLockdown() then return false end
    if not (WorldMapFrame and WorldMapFrame:IsShown()) then SetMapToCurrentZone() end
    local continent=GetCurrentMapContinent()
    -- Learned flying companions establish mount eligibility; passive riding
    -- skills are not reliably visible in the 3.3.5a spellbook.
    return continent==3 or (continent==4 and known(54197))
end
-- Explicit special-speed mounts, including arena and achievement rewards.
local special310={
 [40192]=true, -- Ashes of Al'ar
 [60024]=true, -- Violet Proto-Drake

}
-- Avoid assigning a special speed to an unknown spell from an unverified ID.
-- These mounts can still be classified by their actual tooltip text.
local function tooltipSpeed(spellID)
    tooltip:ClearLines()
    local ok=pcall(tooltip.SetHyperlink,tooltip,'spell:'..spellID)
    if not ok then return nil end
    local best=nil
    for j=2,tooltip:NumLines() do
        local line=_G['SmartTravelScanTooltipTextLeft'..j]
        local str=line and line:GetText()
        if str then
            -- Match explicit mount speed increases, not arbitrary percentages.
            local lower=string.lower(str)
            if string.find(lower,'speed',1,true) or string.find(lower,'movement',1,true) then
                for num in string.gmatch(str,'(%d+)%%') do
                    local n=tonumber(num)
                    if n==60 or n==100 or n==150 or n==280 or n==310 then
                        if not best or n>best then best=n end
                    end
                end
            end
        end
    end
    return best
end
local function speedFor(id,isAir)
    local n=tooltipSpeed(id)
    if isAir then
        if n==310 then return 310 end
        -- A 310% mount can only use its top speed when trained appropriately.
        if special310[id] and known(34091) then return 310 end
        if n==280 and known(34091) then return 280 end
        if n==150 then return 150 end
        if n==280 and not known(34091) then return 0 end
        -- Unknown/scaling flyers: assume trained riding tier, never promise 310.
        return known(34091) and 280 or 150
    end
    if n==100 then return 100 end
    if n==60 then return 60 end
    -- Scaling mounts are only fast on the ground with Journeyman riding.
    return (known(33391) or known(34091)) and 100 or 60
end
local function scan()
    return sharedMountPool(flyable(),false)
end
local function choose(pool,avoid)
    if #pool==0 then return nil end
    if #pool==1 then return pool[1] end
    local options={}
    for _,v in ipairs(pool) do if not avoid or v.id~=avoid then options[#options+1]=v end end
    if #options==0 then options=pool end
    return options[math.random(#options)]
end
local groundSelected=nil
local function chooseGroundOnly()
    local pool=sharedMountPool(false,true)
    if #pool==0 then return nil end
    if groundSelected then
        for _,v in ipairs(pool) do if v.id==groundSelected.id then return v end end
    end
    return pool[math.random(#pool)]
end
local function macroUpdate()
    if InCombatLockdown() then return end
    if onGlobalCooldown() then return end
    -- Ground-mounted regular mount changes dismount first; Hearthstone never does.
    -- The normal mount-selection macro returns after the aura clears.
    local customMount=heldMountOverride()
    local isFlying=selected and selected.rank and selected.rank>=1000
    local ground=isFlying and groundSelected or nil
    local key=hearthMod()
    -- Dismount without changing mounts. Show the mount/action selected by
    -- the current modifier, so releasing Shift restores the flying tooltip.
    if IsMounted() and not IsFlying() then
        -- A selected or fallback Hearthstone must cast on the first press.
        -- Preserve Shaman Ghost Wolf as the default before riding is learned.
        local ghostWolfKnown=playerClass=='SHAMAN' and known(2645)
        local ridingKnown=known(GetSpellInfo(33388) or 'Apprentice Riding')
            or known(GetSpellInfo(33391) or 'Journeyman Riding')
            or known(GetSpellInfo(34090) or 'Expert Riding')
            or known(GetSpellInfo(34091) or 'Artisan Riding')
        local ghostWolfDefault=ghostWolfKnown and not ridingKnown and (GetNumCompanions('MOUNT') or 0)==0
        local hearthstoneSelected=hearthHeld() or (not customMount and not selected and not ghostWolfDefault)
        if hearthstoneSelected then
            writeTravelMacro(table.concat({MANAGED_HEADER,'#showtooltip Hearthstone','/cast [noflying]Hearthstone'},'\n'),message)
        else
            local tooltip=(customMount and customMount.name)
                or (ground and travelHeld() and ground.name)
                or (selected and selected.name) or 'Hearthstone'
            writeTravelMacro(table.concat({MANAGED_HEADER,'#showtooltip '..tooltip,'/dismount [noflying]'},'\n'),message)
        end
        return
    end
    local casts={}
    if key~='none' then casts[#casts+1]='[noflying,mod:'..key..']Hearthstone' end
    local ghostWolf=playerClass=='SHAMAN' and known(2645) and (GetSpellInfo(2645) or 'Ghost Wolf')
    if ghostWolf then
        casts[#casts+1]='[outdoors,combat]'..ghostWolf
        -- Before learning any riding skill, Ghost Wolf is the default travel action.
        local hasRiding=known(GetSpellInfo(33388) or 'Apprentice Riding')
            or known(GetSpellInfo(33391) or 'Journeyman Riding')
            or known(GetSpellInfo(34090) or 'Expert Riding')
            or known(GetSpellInfo(34091) or 'Artisan Riding')
        if not hasRiding and (GetNumCompanions('MOUNT') or 0)==0 then
            casts[#casts+1]=ghostWolf
            local body=table.concat({MANAGED_HEADER,'#showtooltip','/stopmacro [flying]','/cast '..table.concat(casts,';')},'\n')
            writeTravelMacro(body,message)
            return
        end
    end
    if customMount then
        casts[#casts+1]='[noflying]'..customMount.name
    else
        if ground then casts[#casts+1]='[noflying,mod:'..travelCondition()..']'..ground.name end
        if selected then casts[#casts+1]=selected.name
        else casts[#casts+1]='[noflying]Hearthstone' end
    end
    local lines={MANAGED_HEADER,'#showtooltip'}
    lines[#lines+1]='/stopmacro [flying]'
    if #casts>0 then lines[#lines+1]='/cast '..table.concat(casts,';') end
    local body=table.concat(lines,'\n')
    writeTravelMacro(body,message)
end
local function update(force)
    if InCombatLockdown() then return end
    local pool=scan()
    local found=false
    if selected and not force then
        for _,v in ipairs(pool) do if v.id==selected.id then selected=v found=true break end end
    end
    if not found then selected=choose(pool,selected and selected.id) end
    groundSelected=chooseGroundOnly()
    macroUpdate()
end
for _,ev in ipairs({'PLAYER_ENTERING_WORLD','LEARNED_SPELL_IN_TAB',
 'COMPANION_LEARNED','COMPANION_UPDATE','ZONE_CHANGED','ZONE_CHANGED_NEW_AREA',
 'ZONE_CHANGED_INDOORS','PLAYER_REGEN_ENABLED','UNIT_AURA','MODIFIER_STATE_CHANGED'}) do frame:RegisterEvent(ev) end
frame:SetScript('OnEvent',function(_,event) if event=='MODIFIER_STATE_CHANGED' then macroUpdate() else update(false) end end)
frame:SetScript('OnUpdate',function(_,dt)
    elapsed=elapsed+dt
    if elapsed>=0.15 then elapsed=0 update(false) end
end)
refreshTravel=function() update(true) end
SLASH_SMARTTRAVEL1='/st'
SlashCmdList.SMARTTRAVEL=slashSettings
end
-- Register the panel on load so it appears in Interface > AddOns before /st.
showSettings(true)
