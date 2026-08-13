--衛生兵マッスラー
-- 效果：
-- ①：这张卡的战斗让自己或者对方受到战斗伤害的场合，作为代替让基本分回复那个数值。
function c4848423.initial_effect(c)
	-- ①：这张卡的战斗让自己或者对方受到战斗伤害的场合，作为代替让基本分回复那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c4848423.rev)
	c:RegisterEffect(e1)
end
-- 作为伤害替换效果的值函数：若本次伤害是战斗伤害，且效果持有者是该战斗的攻击怪兽或攻击对象怪兽，则返回 true，表示将这次战斗伤害改为回复基本分。
function c4848423.rev(e,re,r,rp,rc)
	local c=e:GetHandler()
	return bit.band(r,REASON_BATTLE)~=0
		-- 进一步判断效果持有者是否就是本次战斗的攻击怪兽或攻击对象，以限定只有本卡参与的战斗造成的伤害才适用反转。
		and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
end
