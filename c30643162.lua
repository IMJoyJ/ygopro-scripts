--ストライク・ショット
-- 效果：
-- 自己场上存在的怪兽攻击宣言时才能发动。那只怪兽的攻击力直到结束阶段时上升700。那只怪兽攻击守备表示怪兽的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c30643162.initial_effect(c)
	-- 自己场上存在的怪兽攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c30643162.target)
	e1:SetOperation(c30643162.activate)
	c:RegisterEffect(e1)
end
-- 那只怪兽的攻击力直到结束阶段时上升700。
function c30643162.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 将攻击怪兽设为目标
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
	-- 将攻击怪兽设为目标
	Duel.SetTargetCard(tg)
end
-- 那只怪兽攻击守备表示怪兽的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c30643162.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使攻击怪兽的攻击力上升700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使攻击怪兽具有贯穿伤害效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
