--sophiaの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以使用各自种族不同的自己场上3只怪兽来作的从手卡的仪式召唤则不能特殊召唤。
-- ①：自己·对方的主要阶段1，从手卡把这张卡和1张「影灵衣」魔法卡丢弃才能发动。那次阶段内，对方不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
function c21105106.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡若非以使用各自种族不同的自己场上3只怪兽来作的从手卡的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c21105106.splimit)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己·对方的主要阶段1，从手卡把这张卡和1张「影灵衣」魔法卡丢弃才能发动。那次阶段内，对方不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c21105106.discon)
	e2:SetCost(c21105106.discost)
	e2:SetOperation(c21105106.disop)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c21105106.rmcon)
	e3:SetCost(c21105106.rmcost)
	e3:SetTarget(c21105106.rmtg)
	e3:SetOperation(c21105106.rmop)
	c:RegisterEffect(e3)
end
-- 规则层面：限制此卡只能通过仪式召唤特殊召唤，且必须从手牌进行仪式召唤。
function c21105106.splimit(e,se,sp,st)
	return e:GetHandler():IsLocation(LOCATION_HAND) and bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
-- 规则层面：过滤函数，用于判断是否为己方场上的怪兽。
function c21105106.mat_filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 规则层面：判断当前是否为主要阶段1。
function c21105106.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断当前是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 规则层面：过滤函数，用于判断是否为「影灵衣」魔法卡且可丢弃。
function c21105106.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 规则层面：判断是否满足丢弃条件，即手牌中有此卡和一张「影灵衣」魔法卡。
function c21105106.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 规则层面：判断是否满足丢弃条件，即手牌中有至少一张「影灵衣」魔法卡。
		and Duel.IsExistingMatchingCard(c21105106.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面：提示玩家选择丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 规则层面：选择一张「影灵衣」魔法卡丢弃。
	local g=Duel.SelectMatchingCard(tp,c21105106.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 规则层面：将选中的卡丢入墓地作为代价。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 规则层面：创建一个效果，使对方在本阶段不能特殊召唤额外怪兽。
function c21105106.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：①：自己·对方的主要阶段1，从手卡把这张卡和1张「影灵衣」魔法卡丢弃才能发动。那次阶段内，对方不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c21105106.sumlimit)
	-- 规则层面：注册效果，使对方不能特殊召唤额外怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面：设定效果目标，限制对方只能特殊召唤额外怪兽。
function c21105106.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 规则层面：判断此卡是否为仪式召唤成功。
function c21105106.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 规则层面：判断是否满足发动条件，即本回合未进行通常召唤和特殊召唤。
function c21105106.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否满足发动条件，即本回合未进行通常召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		-- 规则层面：判断是否满足发动条件，即本回合已进行一次特殊召唤。
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==1 end
	-- 效果原文：②：这张卡仪式召唤时才能发动（这个效果发动的回合，自己不能把其他怪兽通常召唤·特殊召唤）。这张卡以外的双方的场上·墓地的卡全部除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 规则层面：注册效果，使自己不能特殊召唤。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 规则层面：注册效果，使自己不能通常召唤。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	-- 规则层面：注册效果，使自己不能设置怪兽。
	Duel.RegisterEffect(e3,tp)
end
-- 规则层面：设定效果目标，准备将双方场上和墓地的卡除外。
function c21105106.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否满足发动条件，即场上有可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler()) end
	-- 规则层面：获取所有可除外的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	-- 规则层面：设置操作信息，用于连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 规则层面：执行将卡除外的操作。
function c21105106.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取所有可除外的卡，排除此卡本身。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 规则层面：将卡除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 规则层面：判断是否满足仪式召唤条件，即使用3只不同种族的怪兽。
function c21105106.mat_group_check(g)
	return #g==3 and g:GetClassCount(Card.GetRace)==3
end
