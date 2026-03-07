--運命の戦車
-- 效果：
-- 这个卡名在规则上也当作「女武神」卡使用。
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只天使族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
function c39299733.initial_effect(c)
	-- 为卡片注册同盟怪兽机制，使其可以装备给符合条件的怪兽并具有装备怪兽破坏时代替破坏的效果
	aux.EnableUnionAttribute(c,c39299733.filter)
	-- 装备怪兽可以直接攻击
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	-- 那次直接攻击给与对方的战斗伤害变成一半
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetCondition(c39299733.rdcon)
	-- 设置战斗伤害为对方受到的一半
	e6:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e6)
end
-- 定义可以装备的怪兽必须为天使族
function c39299733.filter(c)
	return c:IsRace(RACE_FAIRY)
end
-- 判断是否满足战斗伤害减半的条件，包括未攻击目标、装备怪兽未多次直接攻击、己方场上存在怪兽
function c39299733.rdcon(e)
	local c=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	-- 确保当前没有攻击目标
	return Duel.GetAttackTarget()==nil
		-- 装备怪兽未多次直接攻击且己方场上存在怪兽
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
