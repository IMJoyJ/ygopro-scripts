--城壁壊しの大槍
-- 效果：
-- 装备怪兽攻击里侧守备怪兽的场合，装备怪兽的攻击力上升1500。
function c242146.initial_effect(c)
	-- 调用装备魔法通用辅助函数，为这张卡添加基础的装备效果与装备限制：允许装备给我方或对方场上表侧表示怪兽，且不附加额外的装备数量限制。
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 装备怪兽攻击里侧守备怪兽的场合，装备怪兽的攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c242146.atkcon)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升效果的条件函数：仅在伤害计算阶段，且装备怪兽是攻击怪兽、攻击对象为里侧守备表示怪兽时，攻击力上升效果才适用。
function c242146.atkcon(e)
	-- 若当前不是伤害计算阶段，则直接判定条件不成立。
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eqc=e:GetHandler():GetEquipTarget()
	-- 获取当前进行攻击的怪兽，用于后续判断是否为装备怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽，用于后续判断其是否为里侧守备表示。
	local d=Duel.GetAttackTarget()
	return d and a==eqc and d:GetBattlePosition()==POS_FACEDOWN_DEFENSE
end
