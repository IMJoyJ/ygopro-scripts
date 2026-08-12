--E・HERO ネオス・ナイト
-- 效果：
-- 「元素英雄 新宇侠」＋战士族怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的「元素英雄 新宇侠」以外的怪兽的原本攻击力一半的数值。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡的战斗发生的对对方的战斗伤害变成0。
function c72926163.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「元素英雄 新宇侠」和1只战士族怪兽
	aux.AddFusionProcCodeFun(c,89943723,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为仅能融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的「元素英雄 新宇侠」以外的怪兽的原本攻击力一半的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c72926163.valcheck)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的「元素英雄 新宇侠」以外的怪兽的原本攻击力一半的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c72926163.atkcon)
	e3:SetOperation(c72926163.atkop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：这张卡的战斗发生的对对方的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
end
c72926163.material_setcode=0x8
-- 在融合召唤成功时，检查并记录「元素英雄 新宇侠」以外的另一只素材怪兽的原本攻击力的一半
function c72926163.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	local tc=g:GetFirst()
	if tc:IsCode(89943723) or tc:CheckFusionSubstitute(c) then tc=g:GetNext() end
	if not tc:IsCode(89943723) then
		atk=math.ceil(tc:GetTextAttack()/2)
	end
	e:SetLabel(atk)
end
-- 判断这张卡是否是通过融合召唤特殊召唤成功
function c72926163.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 在融合召唤成功时，使这张卡的攻击力上升之前记录的素材怪兽原本攻击力一半的数值
function c72926163.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()
	if atk>0 then
		-- ①：这张卡的攻击力上升作为这张卡的融合素材的「元素英雄 新宇侠」以外的怪兽的原本攻击力一半的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
