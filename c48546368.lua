--崇光なる宣告者
-- 效果：
-- 「宣告者的神托」降临。这张卡不用仪式召唤不能特殊召唤。
-- ①：可以从手卡把1只天使族怪兽送去墓地把以下效果发动。
-- ●对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ●对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c48546368.initial_effect(c)
	-- 放入「宣告者的神托」的卡名列表
	aux.AddCodeList(c,79306385)
	c:EnableReviveLimit()
	-- 「宣告者的神托」降临。这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为必须通过仪式召唤进行
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：可以从手卡把1只天使族怪兽送去墓地把以下效果发动。●对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
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
	-- ①：可以从手卡把1只天使族怪兽送去墓地把以下效果发动。●对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
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
-- 对方把怪兽的效果·魔法·陷阱卡发动无效并破坏效果的发动条件
function c48546368.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 返回当前发动的效果是怪兽效果或魔法·陷阱卡的发动且该连锁可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤手卡的天使族且能送去墓地作为代价的怪兽
function c48546368.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
-- 对方把怪兽的效果·魔法·陷阱卡发动无效并破坏/特殊召唤无效并破坏效果的发动代价
function c48546368.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：手卡是否存在满足条件的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48546368.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡将一只满足条件的天使族怪兽送去墓地
	Duel.DiscardHand(tp,c48546368.cfilter,1,1,REASON_COST)
end
-- 对方把怪兽的效果·魔法·陷阱卡发动无效并破坏效果的靶点
function c48546368.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效当前发动的连锁
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏被无效连锁发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 对方把怪兽的效果·魔法·陷阱卡发动无效并破坏效果的处理
function c48546368.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效当前发动且被无效的卡存在于合理位置
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤由对方特殊召唤的怪兽
function c48546368.filter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 对方特殊召唤无效效果的发动条件
function c48546368.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前不在连锁中且存在对方特殊召唤的怪兽
	return Duel.GetCurrentChain()==0 and eg:IsExists(c48546368.filter,1,nil,1-tp)
end
-- 对方特殊召唤无效效果的靶点
function c48546368.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c48546368.filter,nil,1-tp)
	-- 设置操作信息：无效这批怪兽的特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置操作信息：破坏这批怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 对方特殊召唤无效效果的处理
function c48546368.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c48546368.filter,nil,1-tp)
	-- 无效目标怪兽的特殊召唤
	Duel.NegateSummon(g)
	-- 破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
