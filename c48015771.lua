--サモンオーバー
-- 效果：
-- ①：每次怪兽特殊召唤给这张卡放置1个召唤指示物（最多6个）。
-- ②：有6个召唤指示物放置的这张卡不会被效果破坏。
-- ③：这张卡有6个召唤指示物放置的场合，双方玩家在自己主要阶段1开始时才能发动。这张卡送去墓地，对方场上的特殊召唤的怪兽全部送去墓地。
function c48015771.initial_effect(c)
	c:EnableCounterPermit(0x4c)
	c:SetCounterLimit(0x4c,6)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次怪兽特殊召唤给这张卡放置1个召唤指示物（最多6个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c48015771.ctop)
	c:RegisterEffect(e2)
	-- ②：有6个召唤指示物放置的这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c48015771.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡有6个召唤指示物放置的场合，双方玩家在自己主要阶段1开始时才能发动。这张卡送去墓地，对方场上的特殊召唤的怪兽全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48015771,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c48015771.tgcon)
	e4:SetTarget(c48015771.tgtg)
	e4:SetOperation(c48015771.tgop)
	c:RegisterEffect(e4)
end
c48015771.mentioned_counter={
	[0x4c]=true,
}
-- 每次怪兽特殊召唤成功时，给这张卡放置1个召唤指示物。
function c48015771.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4c,1)
end
-- 这张卡放置了6个召唤指示物的场合，此效果才适用。
function c48015771.indcon(e)
	return e:GetHandler():GetCounter(0x4c)==6
end
-- 发动条件：当前是自己主要阶段1的开始时（该阶段尚未进行任何操作），且这张卡放置了6个召唤指示物。
function c48015771.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 只有处于主要阶段1且该阶段尚无操作（即阶段开始时），并且这张卡有6个召唤指示物时才能发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() and e:GetHandler():GetCounter(0x4c)==6
end
-- 过滤条件：表侧表示、特殊召唤而来、且可以送去墓地的怪兽。
function c48015771.tgfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToGrave()
end
-- 处理这个效果的目标选择：先检查能否发动，再取得对方场上所有特殊召唤的怪兽，并设置送去墓地的操作信息。
function c48015771.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：对方怪兽区至少要存在1只特殊召唤的表侧表示怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48015771.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方怪兽区所有满足条件（特殊召唤的表侧表示）的怪兽。
	local g=Duel.GetMatchingGroup(c48015771.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：预计将这些怪兽全部作为送去墓地的处理对象，数量为卡组中的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：先把这张卡送去墓地，成功后再将对方场上所有特殊召唤的怪兽全部送去墓地。
function c48015771.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡仍与此效果相关联，且成功以效果原因送去墓地并确实位于墓地时，才执行后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 在处理时重新取得对方怪兽区所有特殊召唤的表侧表示怪兽。
		local g=Duel.GetMatchingGroup(c48015771.tgfilter,tp,0,LOCATION_MZONE,nil)
		-- 将这组怪兽以效果原因全部送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
