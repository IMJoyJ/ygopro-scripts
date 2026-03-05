--毒サソリの罠
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。那只怪兽破坏。那之后，给与对方300伤害。
local s,id,o=GetID()
-- 注册陷阱卡效果，设置其为发动时点、破坏与伤害类别、条件、目标和效果处理函数
function s.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。那只怪兽破坏。那之后，给与对方300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为对方怪兽直接攻击宣言，且攻击对象为空
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的直接攻击宣言时才能发动
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
end
-- 设置效果处理时的目标信息，包括破坏攻击怪兽和给予对方300伤害
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsOnField() end
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行效果处理，破坏攻击怪兽并给予对方伤害
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽是否与本次战斗相关且为怪兽类型，并尝试破坏
	if at:IsRelateToBattle() and at:IsType(TYPE_MONSTER) and Duel.Destroy(at,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，防止后续效果错时触发
		Duel.BreakEffect()
		-- 给予对方300伤害
		Duel.Damage(1-tp,300,REASON_EFFECT)
	end
end
