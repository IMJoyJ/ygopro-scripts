--崇光なる宣告者
-- 效果：
-- 「宣告者的神托」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：可以从手卡把1只天使族怪兽送去墓地把以下效果发动。
-- ●对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c48546368.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：「宣告者的神托」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 规则层面操作：设置此卡必须通过仪式召唤才能特殊召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：可以从手卡把1只天使族怪兽送去墓地把以下效果发动。●对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48546368,0))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c48546368.negcon)
	e2:SetCost(c48546368.cost)
	e2:SetTarget(c48546368.negtg)
	e2:SetOperation(c48546368.negop)
	c:RegisterEffect(e2)
	-- 效果原文内容：●对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48546368,1))  --"无效并破坏"
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCondition(c48546368.discon)
	e3:SetCost(c48546368.cost)
	e3:SetTarget(c48546368.distg)
	e3:SetOperation(c48546368.disop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断是否为对方怪兽效果或魔法/陷阱卡的发动，并且该连锁可以被无效
function c48546368.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 规则层面操作：检查连锁是否能被无效（即发动的是怪兽效果或魔法/陷阱卡）
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 规则层面操作：定义过滤函数，用于筛选手牌中可作为代价送去墓地的天使族怪兽
function c48546368.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 规则层面操作：消耗1张手牌中的天使族怪兽作为代价进行丢弃
function c48546368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足丢弃条件（即手牌中有至少1张天使族怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c48546368.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：执行丢弃手牌中符合条件的1张天使族怪兽的操作
	Duel.DiscardHand(tp,c48546368.cfilter,1,1,REASON_COST)
end
-- 规则层面操作：设置连锁处理时要无效并破坏的目标对象信息
function c48546368.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁处理时要无效的目标（即对方发动的卡）
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：设置连锁处理时要破坏的目标（即对方发动的卡）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面操作：执行连锁无效和目标破坏的操作
function c48546368.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否成功使连锁无效且目标卡存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：对满足条件的目标卡进行破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 规则层面操作：定义过滤函数，用于筛选被对方特殊召唤的怪兽
function c48546368.filter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 规则层面操作：判断当前无连锁处理中且有对方特殊召唤的怪兽
function c48546368.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查当前没有连锁正在处理，并且存在对方特殊召唤的怪兽
	return Duel.GetCurrentChain()==0 and eg:IsExists(c48546368.filter,1,nil,1-tp)
end
-- 规则层面操作：设置连锁处理时要无效并破坏的目标对象信息（针对特殊召唤）
function c48546368.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c48546368.filter,nil,1-tp)
	-- 规则层面操作：设置连锁处理时要无效的目标（即对方特殊召唤的怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 规则层面操作：设置连锁处理时要破坏的目标（即对方特殊召唤的怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行连锁无效和目标破坏的操作（针对特殊召唤）
function c48546368.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c48546368.filter,nil,1-tp)
	-- 规则层面操作：使目标怪兽的召唤无效
	Duel.NegateSummon(g)
	-- 规则层面操作：对满足条件的目标怪兽进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
