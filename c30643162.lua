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
-- 效果的目标处理函数：在 chk=0 的发动合法性检查中，确认攻击怪兽是我方场上怪兽；合法后将该攻击怪兽设置为效果对象。
function c30643162.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前进行攻击宣言的怪兽。
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
	-- 将这只攻击怪兽设置为当前连锁效果的对象（取对象效果），使该怪兽与效果建立关联。
	Duel.SetTargetCard(tg)
end
-- 效果解决时的处理函数：确认攻击怪兽仍与效果相关且表侧表示在场，然后为其附加攻击力上升700和贯穿伤害效果，直到结束阶段。
function c30643162.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时正在攻击的怪兽。
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到结束阶段时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽攻击守备表示怪兽的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
