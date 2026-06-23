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
-- 判断伤害是否由战斗造成且该卡为攻击怪兽或被攻击怪兽
function c4848423.rev(e,re,r,rp,rc)
	local c=e:GetHandler()
	return bit.band(r,REASON_BATTLE)~=0
		-- 判断该卡是否为此次战斗的攻击怪兽或防守怪兽
		and (c==Duel.GetAttacker() or c==Duel.GetAttackTarget())
end
