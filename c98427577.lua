--くず鉄のかかし
-- 效果：
-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效。发动后这张卡不送去墓地，直接盖放。
function c98427577.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效。发动后这张卡不送去墓地，直接盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c98427577.condition)
	e1:SetTarget(c98427577.target)
	e1:SetOperation(c98427577.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件
function c98427577.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（即对方怪兽的攻击宣言）
	return tp~=Duel.GetTurnPlayer()
end
-- 效果的目标选择与合法性检查
function c98427577.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前宣布攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将宣布攻击的怪兽设为效果的对象
	Duel.SetTargetCard(tg)
end
-- 效果处理（无效攻击，并将这张卡直接盖放）
function c98427577.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该怪兽的攻击
	Duel.NegateAttack()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() then
		-- 中断效果处理，使后续的盖放处理与无效攻击不同时处理
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将这张卡转为里侧表示（盖放）
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发盖放魔法·陷阱卡的时点
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
