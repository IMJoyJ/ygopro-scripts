--城壁壊しの大槍
-- 效果：
-- 装备怪兽攻击里侧守备怪兽的场合，装备怪兽的攻击力上升1500。
function c242146.initial_effect(c)
	-- 为装备魔法卡注册标准的发动效果与装备限制，允许装备给己方或对方场上满足条件的怪兽，装备目标需为表侧表示
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 装备怪兽攻击里侧守备怪兽的场合，装备怪兽的攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c242146.atkcon)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
end
-- 定义装备怪兽攻击里侧守备怪兽时触发的条件函数
function c242146.atkcon(e)
	-- 判断当前阶段是否为伤害计算阶段
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eqc=e:GetHandler():GetEquipTarget()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	return d and a==eqc and d:GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
