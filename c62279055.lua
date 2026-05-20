--魔法の筒
-- 效果：
-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击无效，给与对方那个攻击力数值的伤害。
function c62279055.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击无效，给与对方那个攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c62279055.condition)
	e1:SetTarget(c62279055.target)
	e1:SetOperation(c62279055.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：判断是否满足发动条件
function c62279055.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家不是自己（即对方怪兽宣言攻击）
	return tp~=Duel.GetTurnPlayer()
end
-- 效果发动时的目标选择与处理函数：确认并锁定攻击怪兽为效果对象，并预设伤害操作信息
function c62279055.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设为效果的对象
	Duel.SetTargetCard(tg)
	local dam=tg:GetAttack()
	-- 设置操作信息，表示该连锁处理中确定会给与对方相当于该怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理（卡片发动）函数：使对象怪兽的攻击无效，并给与对方其攻击力数值的伤害
function c62279055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时成为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试无效该怪兽的攻击，若成功则继续执行后续效果
		if Duel.NegateAttack() then
			-- 给与对方相当于该怪兽攻击力数值的效果伤害
			Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
		end
	end
end
