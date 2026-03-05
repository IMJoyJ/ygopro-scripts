--銀河の施し
-- 效果：
-- 自己场上有名字带有「银河」的超量怪兽存在的场合，丢弃1张手卡才能发动。从卡组抽2张卡。这张卡发动过的回合，对方受到的全部伤害变成一半。「银河的施舍」在1回合只能发动1张。
function c20349913.initial_effect(c)
	-- 效果原文内容：自己场上有名字带有「银河」的超量怪兽存在的场合，丢弃1张手卡才能发动。从卡组抽2张卡。这张卡发动过的回合，对方受到的全部伤害变成一半。「银河的施舍」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20349913+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20349913.condition)
	e1:SetCost(c20349913.cost)
	e1:SetTarget(c20349913.target)
	e1:SetOperation(c20349913.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在名字带有「银河」的超量怪兽
function c20349913.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7b) and c:IsType(TYPE_XYZ)
end
-- 效果作用：判断是否满足发动条件，即自己场上有名字带有「银河」的超量怪兽
function c20349913.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否存在名字带有「银河」的超量怪兽
	return Duel.IsExistingMatchingCard(c20349913.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：支付发动费用，丢弃1张手卡
function c20349913.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否可以支付发动费用
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果作用：设置效果目标，准备抽2张卡
function c20349913.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置抽卡的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置抽卡数量为2
	Duel.SetTargetParam(2)
	-- 效果作用：设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行效果，进行抽卡并设置伤害减半效果
function c20349913.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 效果原文内容：这张卡发动过的回合，对方受到的全部伤害变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(c20349913.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 效果作用：注册伤害变更效果，使对方受到的伤害减半
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果作用：定义伤害减半的计算函数，将伤害值除以2并向下取整
function c20349913.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
