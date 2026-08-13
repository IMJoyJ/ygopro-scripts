--運命の戦車
-- 效果：
-- 这个卡名在规则上也当作「女武神」卡使用。
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只天使族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ②：装备怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
function c39299733.initial_effect(c)
	-- 调用辅助函数为这张卡注册同盟怪兽的通用效果（装备、代破、特殊召唤等），装备对象限定为天使族怪兽。
	aux.EnableUnionAttribute(c,c39299733.filter)
	-- ②：装备怪兽可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetCondition(c39299733.rdcon)
	-- 设置战斗伤害变更效果：对方因这次直接攻击受到的战斗伤害变为一半。
	e6:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e6)
end
-- 过滤函数：只有天使族怪兽才能成为这张卡的装备对象。
function c39299733.filter(c)
	return c:IsRace(RACE_FAIRY)
end
-- 伤害减半效果的适用条件：装备怪兽正在进行直接攻击，且对方场上有怪兽，并且直接攻击效果数量正常。
function c39299733.rdcon(e)
	local c=e:GetHandler():GetEquipTarget()
	local tp=e:GetHandlerPlayer()
	-- 检查当前战斗阶段是否没有攻击对象，即是否正在进行直接攻击。
	return Duel.GetAttackTarget()==nil
		-- 进一步确认装备怪兽具备直接攻击能力（效果数量未异常叠加），且对方场上有怪兽，保证只有通过效果进行的直接攻击才减半。
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
