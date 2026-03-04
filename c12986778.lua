--機皇帝の賜与
-- 效果：
-- 场上表侧表示存在的怪兽只有名字带有「机皇」的怪兽2只的场合才能发动。从自己卡组抽2张卡。这张卡发动的回合，自己不能进行战斗阶段。
function c12986778.initial_effect(c)
	-- 效果原文内容：场上表侧表示存在的怪兽只有名字带有「机皇」的怪兽2只的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c12986778.condition)
	e1:SetCost(c12986778.cost)
	e1:SetTarget(c12986778.target)
	e1:SetOperation(c12986778.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否只有2只名字带有「机皇」的怪兽表侧表示存在
function c12986778.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetCount()==2 and g:GetFirst():IsSetCard(0x13) and g:GetNext():IsSetCard(0x13)
end
-- 效果作用：设置发动时的费用条件
function c12986778.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查当前阶段是否为主要阶段1
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 效果原文内容：从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将不能进入战斗阶段的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：设置发动时的目标
function c12986778.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁处理的目标参数为2
	Duel.SetTargetParam(2)
	-- 效果作用：设置连锁操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：设置发动时的处理效果
function c12986778.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁处理的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行从卡组抽2张卡的效果
	Duel.Draw(p,d,REASON_EFFECT)
end
