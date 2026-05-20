--墓地墓地の恨み
-- 效果：
-- ①：对方墓地的卡是8张以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
function c67113830.initial_effect(c)
	-- ①：对方墓地的卡是8张以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c67113830.condition)
	e1:SetTarget(c67113830.target)
	e1:SetOperation(c67113830.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件，需满足不在伤害计算后且对方墓地卡片数量在8张以上
function c67113830.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前时点是否在伤害步骤中且非伤害计算后
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp)
		-- 判定对方墓地的卡片数量是否在8张以上（大于7张）
		and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>7
end
-- 过滤出对方场上表侧表示且攻击力大于0的怪兽
function c67113830.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 判定效果发动的合法性，检查对方场上是否存在符合条件的怪兽
function c67113830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在至少1只表侧表示且攻击力大于0的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67113830.filter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理，获取对方场上所有表侧表示的怪兽并将其攻击力变成0
function c67113830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
