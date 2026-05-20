--エレキャンセル
-- 效果：
-- 从手卡丢弃1只名字带有「电气」的怪兽发动。对方怪兽的召唤·特殊召唤无效并破坏。
function c56993276.initial_effect(c)
	-- 从手卡丢弃1只名字带有「电气」的怪兽发动。对方怪兽的召唤·特殊召唤无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c56993276.condition)
	e1:SetCost(c56993276.cost)
	e1:SetTarget(c56993276.target)
	e1:SetOperation(c56993276.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
end
-- 定义发动条件：当前没有正在处理的连锁，且被召唤·特殊召唤的怪兽中存在对方控制的怪兽
function c56993276.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于非连锁状态下的召唤时点，且被召唤的怪兽中包含对方的怪兽
	return aux.NegateSummonCondition() and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤条件：手卡中名字带有「电气」的怪兽且可以丢弃
function c56993276.cfilter(c)
	return c:IsSetCard(0xe) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 定义发动代价：从手卡丢弃1只名字带有「电气」的怪兽
function c56993276.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若受到反制陷阱丢弃手卡代替效果（如解放之阿里阿德涅）的影响，则无需支付丢弃手卡的代价
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	-- 在发动检查阶段，判断手卡中是否存在至少1张满足过滤条件的「电气」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56993276.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，选择并丢弃1张手卡中名字带有「电气」的怪兽
	Duel.DiscardHand(tp,c56993276.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义效果的目标：筛选出对方被召唤·特殊召唤的怪兽，并设置无效召唤和破坏的操作信息
function c56993276.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	-- 设置操作信息：无效这些怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果的处理：使对方怪兽的召唤·特殊召唤无效并破坏
function c56993276.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	-- 使正在召唤·特殊召唤的对方怪兽的召唤无效
	Duel.NegateSummon(g)
	-- 破坏这些召唤被无效的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
