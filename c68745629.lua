--E・HERO フレイム・ブラスト
-- 效果：
-- 「元素英雄 炽热侠」＋「元素英雄 火焰女郎」
-- 这只怪兽不能作融合召唤以外的特殊召唤。和水属性怪兽战斗的场合，伤害步骤内这只怪兽的攻击力上升1000。
function c68745629.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定「元素英雄 炽热侠」和「元素英雄 火焰女郎」为融合素材
	aux.AddFusionProcCode2(c,98266377,95362816,true,true)
	-- 这只怪兽不能作融合召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅限融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 和水属性怪兽战斗的场合，伤害步骤内这只怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c68745629.atkcon)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
c68745629.material_setcode=0x8
-- 判断自身是否在伤害步骤与表侧表示的水属性怪兽进行战斗
function c68745629.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL then return false end
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsAttribute(ATTRIBUTE_WATER)
end
