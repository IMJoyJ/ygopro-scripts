--幻層の守護者アルマデス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·效果怪兽的效果不能发动。
function c88033975.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·效果怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c88033975.actcon)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数，判断此卡是否进行战斗
function c88033975.actcon(e)
	-- 判断当前战斗的攻击方或被攻击方是否为这张卡自身
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
