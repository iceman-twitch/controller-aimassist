local Enabled = CreateConVar( "m_customaim_enabled", 1, { FCVAR_ARCHIVE } )
CreateConVar( "m_customaim_y", 0.3, { FCVAR_ARCHIVE } )
CreateConVar( "m_customaim_x", 0.3, { FCVAR_ARCHIVE } )
local lastenemy = NULL
local aimingtime = 0
local proximityThreshold = 6000 -- Adjust this distance as needed
local nearestenemy = {}
local targetlist = {
["player"] = true,
-- ["npc_combine_s"] = true,
-- ["npc_citizen"] = true,
-- ["npc_alyx"] = true,
-- ["npc_headcrab"] = true
}
lerped = Angle( 0, 0, 0 )
local nextcur = 0.001
local time = 0
local turnoff = false
local mouse_time = 0
local function CheckTarget( class )
    
    return targetlist[class] or false
    
end

local function IsPlayerNearEnemy(ply)
    -- LocalPlayer():ChatPrint( "I'm new here." )
    for _, ent in pairs(ents.FindInSphere( ply:GetPos(), proximityThreshold ) ) do
    
        if ent != ply and CheckTarget( ent:GetClass() ) then
            return true
            
        end
        
    end
    
    return false
end

local function GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

hook.Add( "Think", "AimBot0.1", function()
    if CurTime() > mouse_time and turnoff then lastenemy = NULL turnoff = false end
    if turnoff then return end
    if CurTime() > aimingtime then aimingtime = 0 lastenemy = NULL end
    local ply = LocalPlayer()
    local viewAngles = ply:EyeAngles()
    local forward = viewAngles:Forward()
    
    -- Trace from the player's eyes to check if they are looking at an enemy
    local traceData = {
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + forward * 2000, -- Adjust the distance as needed
        -- mask = MASK_SHOT,
        filter = {ply,lastenemy}
    }
    local tr = util.TraceLine(traceData)
    
    if tr.Hit and IsValid( tr.Entity ) and CheckTarget( tr.Entity:GetClass() ) and tr.Entity != ply and lastenemy == NULL then
        -- LocalPlayer():ChatPrint( "tracing?" )
        lastenemy = tr.Entity
        
    end
    if IsValid( lastenemy ) then
    
        if lastenemy:Health() < 1 then
        
            lastenemy = NULL
            lerped = Vector( 0, 0, 0 )
            return
            
        end
        if CurTime() > time then
            time = CurTime() + nextcur
            local start = ply:GetShootPos()
            local aim = ply:GetAimVector()
            local endpos = GetHeadPos(lastenemy)
            
            if not isangle( lerped ) then lerped = Angle( 0, 0, 0 ) end
            local angle = ( ( (endpos - start):Angle() ) )
            if lerped == Angle( 0, 0, 0 )then
            
                lerped = LerpAngle( 0.55, ply:LocalEyeAngles(), angle )
            
            else
            
                lerped = LerpAngle( 0.125, lerped, angle )
                
            end
            aimingtime = CurTime() + 2
            ply:SetEyeAngles( lerped ) 
        end
        
    elseif not IsValid( lastenemy ) and lastenemy != NULL then
    
        lastenemy = NULL
        lerped = Vector( 0, 0, 0 )
        
    end
end)


hook.Add( "InputMouseApply", "AimAssistModif", function( cmd, x, y, angle )
    
    if x > 4 or x < -4 then
        -- print(x)
        -- LocalPlayer():ChatPrint("Mouse MOVES?" )
        turnoff = true
        mouse_time = CurTime() + 0.05
    end
	--if(!Enabled:GetBool()) then return end    
    -- local pitchchange = y * GetConVar( "m_pitch" ):GetFloat() * GetConVar( "m_customaim_y" ):GetFloat()
    -- local yawchange = x * GetConVar( "m_yaw" ):GetFloat() * GetConVar( "m_customaim_x" ):GetFloat()
	-- local ply = LocalPlayer()
    -- local viewAngles = cmd:GetViewAngles()
        -- local forward = viewAngles:Forward()
    -- Trace from the player's eyes to check if they are looking at an enemy
        -- local traceData = {
            -- start = ply:GetShootPos(),
            -- endpos = ply:GetShootPos() + forward * 2000, -- Adjust the distance as needed
            -- filter = ply
        -- }
        -- local traceResult = util.TraceLine(traceData)

        -- if traceResult.Hit and traceResult.Entity:IsValid() and traceResult.Entity:IsPlayer() and traceResult.Entity != ply then
            -- local newAngles = (traceResult.Entity:GetPos() - ply:GetShootPos()):Angle()
            -- local angleDifference = (newAngles - viewAngles)
            -- lastenemy = traceResult.Entity
        -- end
    -- if IsValid( lastenemy ) then
            -- print(lastenemy)
            -- local start = ply:GetShootPos()
            -- local endpos = lastenemy:GetPos()
            -- ply:SetEyeAngles( (start - endpos):Angle() )
    -- if IsValid(ply) and IsPlayerNearEnemy(ply) then
        
        

        
            

    --angle.p = angle.p + pitchchange
    --angle.y = angle.y + yawchange * -1

    -- cmd:SetViewAngles( angle )
    
        
    -- return true
	-- end
	-- end
end)


hook.Add( "AddToolMenuCategories", "AimAssistCategory", function()
	spawnmenu.AddToolCategory( "Options", "Custom Aim Assist", "#Aim Assist" )
end)

hook.Add( "PopulateToolMenu", "AimAssistSettingsMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Custom Aim Assist", "Custom_Aim_Assist", "#Aim Assist", "", "", function(pan)
		pan:ClearControls()
		pan:CheckBox( "Enable Aim Assist", "m_customaim_enabled" )
		pan:NumSlider( "X Sensitivity (Horizontal)", "m_customaim_x", 0, 1, 1 )
		pan:NumSlider( "Y Sensitivity (Vertical)", "m_customaim_y", 0, 1, 1 )
	end)
end)