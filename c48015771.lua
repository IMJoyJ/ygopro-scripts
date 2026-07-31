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
-- 规则层面：每当有怪兽特殊召唤成功时，将1个召唤指示物放置到此卡上。
function c48015771.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x4c,1)
end
-- 规则层面：当此卡拥有6个召唤指示物时，满足条件使此卡不会被效果破坏。
function c48015771.indcon(e)
	return e:GetHandler():GetCounter(0x4c)==6
end
-- 规则层面：判断是否处于主要阶段1开始时且己方未进行过操作，同时此卡拥有6个召唤指示物。
function c48015771.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：当前阶段为主要阶段1，且未进行过操作，同时此卡拥有6个召唤指示物。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() and e:GetHandler():GetCounter(0x4c)==6
end
-- 规则层面：过滤条件，筛选场上正面表示特殊召唤的怪兽（可送去墓地）。
function c48015771.tgfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToGrave()
end
-- 规则层面：设置连锁处理信息，确定效果发动时将要处理的对方场上的特殊召唤怪兽。
function c48015771.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否有满足条件的对方场上的特殊召唤怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48015771.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面：获取所有满足条件的对方场上的特殊召唤怪兽。
	local g=Duel.GetMatchingGroup(c48015771.tgfilter,tp,0,LOCATION_MZONE,nil)
	-- 规则层面：设置效果处理信息，指定要将这些怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 规则层面：执行效果处理，将此卡送去墓地，并将对方场上所有满足条件的怪兽送去墓地。
function c48015771.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：判断此卡是否还在场上且已成功送去墓地，以继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 规则层面：获取所有满足条件的对方场上的特殊召唤怪兽。
		local g=Duel.GetMatchingGroup(c48015771.tgfilter,tp,0,LOCATION_MZONE,nil)
		-- 规则层面：将这些怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
