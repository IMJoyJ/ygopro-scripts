--陽気な葬儀屋
-- 效果：
-- 从自己的手卡中丢弃最多3张怪兽卡送去墓地。
function c41142615.initial_effect(c)
	-- 从自己的手卡中丢弃最多3张怪兽卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41142615.target)
	e1:SetOperation(c41142615.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡片是否为怪兽卡。
function c41142615.filter(c)
	return c:IsType(TYPE_MONSTER)
end
-- 效果的发动时点处理函数，用于确认是否满足发动条件并设置操作信息。
function c41142615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看，手牌中是否存在至少1张满足过滤条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c41142615.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前处理的连锁的操作信息为CATEGORY_HANDES（丢弃手牌），预计丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果发动时的处理函数，执行丢弃手牌的操作。
function c41142615.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家tp选择并丢弃1到3张满足条件的怪兽卡，丢弃原因为效果与丢弃。
	Duel.DiscardHand(tp,c41142615.filter,1,3,REASON_EFFECT+REASON_DISCARD)
end
