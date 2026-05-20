--悪夢の迷宮
-- 效果：
-- 在每1个回合的结束阶段时，变更该回合行动玩家场上所有以表侧表示存在的怪兽的表示形式。
function c66526672.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 在每1个回合的结束阶段时，变更该回合行动玩家场上所有以表侧表示存在的怪兽的表示形式。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66526672,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetTarget(c66526672.postg)
	e2:SetOperation(c66526672.posop)
	c:RegisterEffect(e2)
end
-- 设置结束阶段变更表示形式效果的发动条件与操作信息
function c66526672.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认当前回合玩家场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil) end
	-- 获取当前回合玩家场上所有表侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,Duel.GetTurnPlayer(),LOCATION_MZONE,0,nil)
	-- 设置连锁中的操作信息为改变上述怪兽组的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行结束阶段变更表示形式效果的具体操作
function c66526672.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家场上所有表侧表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,Duel.GetTurnPlayer(),LOCATION_MZONE,0,nil)
	-- 将目标怪兽组中表侧攻击表示的变更为表侧守备表示，表侧守备表示的变更为表侧攻击表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
