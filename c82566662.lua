--トウテツドラゴン
-- 效果：
-- 从额外卡组特殊召唤的怪兽2只以上
-- ①：这张卡得到作为这张卡的连接素材的怪兽种类的以下效果。
-- ●融合：战斗阶段中对方不能把怪兽的效果发动。
-- ●同调：自己主要阶段中对方不能把魔法·陷阱卡的效果发动。
-- ●超量：自己的主要阶段以及战斗阶段中对方不能把墓地的卡的效果发动。
function c82566662.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只以上满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c82566662.matfilter,2)
	-- ①：这张卡得到作为这张卡的连接素材的怪兽种类的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c82566662.regcon)
	e1:SetOperation(c82566662.regop)
	c:RegisterEffect(e1)
end
-- 过滤条件：从额外卡组特殊召唤的怪兽
function c82566662.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 检查这张卡是否是通过连接召唤特殊召唤的
function c82566662.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 根据作为连接素材的怪兽种类（融合、同调、超量），分别为这张卡注册对应的永续效果
function c82566662.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetMaterial():FilterCount(Card.IsLinkType,nil,TYPE_FUSION)>0 then
		-- ●融合：战斗阶段中对方不能把怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetTargetRange(0,1)
		e1:SetCondition(c82566662.condition1)
		e1:SetValue(c82566662.aclimit1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(82566662,0))  --"融合怪兽作为连接素材"
	end
	if c:GetMaterial():FilterCount(Card.IsLinkType,nil,TYPE_SYNCHRO)>0 then
		-- ●同调：自己主要阶段中对方不能把魔法·陷阱卡的效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetTargetRange(0,1)
		e2:SetCondition(c82566662.condition2)
		e2:SetValue(c82566662.aclimit2)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(82566662,1))  --"同调怪兽作为连接素材"
	end
	if c:GetMaterial():FilterCount(Card.IsLinkType,nil,TYPE_XYZ)>0 then
		-- ●超量：自己的主要阶段以及战斗阶段中对方不能把墓地的卡的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetTargetRange(0,1)
		e3:SetCondition(c82566662.condition3)
		e3:SetValue(c82566662.aclimit3)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(82566662,2))  --"超量怪兽作为连接素材"
	end
end
-- 融合素材效果的适用条件：当前处于战斗阶段
function c82566662.condition1(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 限制发动的卡片类型：怪兽的效果
function c82566662.aclimit1(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 同调素材效果的适用条件：自己回合的主要阶段
function c82566662.condition2(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为自己回合的主要阶段1或主要阶段2
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 限制发动的卡片类型：魔法·陷阱卡的效果
function c82566662.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 超量素材效果的适用条件：自己回合的主要阶段或战斗阶段
function c82566662.condition3(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
		-- 并且当前回合玩家是自己
		and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 限制发动的卡片位置：在墓地发动的卡的效果
function c82566662.aclimit3(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
