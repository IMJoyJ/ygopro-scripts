--レプティアの武者騎兵
-- 效果：
-- ←3 【灵摆】 3→
-- 【怪兽效果】
-- ①：这张卡向灵摆怪兽以外的对方的表侧表示怪兽攻击的伤害步骤开始时才能发动。那只怪兽破坏。
function c93124273.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、作为灵摆卡发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡向灵摆怪兽以外的对方的表侧表示怪兽攻击的伤害步骤开始时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93124273,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(c93124273.target)
	e2:SetOperation(c93124273.operation)
	c:RegisterEffect(e2)
end
-- 检查发动条件：自身进行攻击，且攻击目标为非灵摆怪兽的对方表侧表示怪兽
function c93124273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的被攻击怪兽（攻击目标）
	local d=Duel.GetAttackTarget()
	-- 在chk==0时，检查自身是否为攻击怪兽，且攻击目标存在、表侧表示且不是灵摆怪兽
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d and d:IsFaceup() and not d:IsType(TYPE_PENDULUM) end
	-- 设置操作信息，表示该效果的处理为破坏1个目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理：若攻击目标仍与战斗相关联，则将其因效果破坏
function c93124273.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将该怪兽因效果破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
