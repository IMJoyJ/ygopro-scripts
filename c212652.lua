--毒サソリの罠
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。那只怪兽破坏。那之后，给与对方300伤害。
local s,id,o=GetID()
-- 定义并注册该卡的发动效果：在对方怪兽直接攻击宣言时满足条件则可发动，效果处理时将攻击怪兽破坏并给予对方300伤害。
function s.initial_effect(c)
	-- 对应效果原文“①：对方怪兽的直接攻击宣言时才能发动。那只怪兽破坏。那之后，给与对方300伤害。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：当前为对方回合且本次攻击没有攻击对象（即直接攻击）时才允许发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件成立：非回合玩家（对方回合）且攻击目标为空（直接攻击宣言）。
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
end
-- 效果发动时的目标选择与操作信息设置：获取攻击怪兽，在发动时确认其仍在场上，然后登记破坏该怪兽和造成300伤害的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的怪兽作为预定破坏对象。
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsOnField() end
	-- 登记破坏操作：预定破坏对象tc（攻击怪兽），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 登记伤害操作：预定对对方玩家（1-tp）造成300点伤害，对象不确定（效果处理时判定）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理函数：获取当前攻击怪兽，若其仍与本次战斗关联且为怪兽，则将其破坏；若破坏成功，则中断时点后给予对方300伤害。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽，用于后续破坏判定。
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽仍与本次战斗相关且是怪兽，并以效果将其破坏；若破坏成功（返回非0）则继续处理伤害。
	if at:IsRelateToBattle() and at:IsType(TYPE_MONSTER) and Duel.Destroy(at,REASON_EFFECT)~=0 then
		-- 中断当前效果连锁，使后续伤害给予与前面的破坏处理不同时进行，以正确触发时点。
		Duel.BreakEffect()
		-- 给予对方玩家（1-tp）300点效果伤害。
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end
