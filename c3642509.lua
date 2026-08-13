--E・HERO Great TORNADO
-- 效果：
-- 「元素英雄」怪兽＋风属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡融合召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力变成一半。
function c3642509.initial_effect(c)
	c:EnableReviveLimit()
	-- 为此卡添加融合召唤手续：以‘元素英雄’怪兽和风属性怪兽各1只作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WIND),true)
	-- ①：这张卡融合召唤成功的场合发动。对方场上的全部怪兽的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3642509,0))  --"攻守变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c3642509.atkcon)
	e2:SetOperation(c3642509.atkop)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 配置该特殊召唤条件效果的值，使此卡只能以融合召唤（SUMMON_TYPE_FUSION）方式特殊召唤，其他特殊召唤方式均不能进行。
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c3642509.material_setcode=0x8
-- 判定条件是此卡是否以融合召唤方式特殊召唤成功；只有融合召唤成功时，后面的诱发效果才能发动。
function c3642509.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果处理：获取对方场上全部表侧表示怪兽，将每只怪兽当前的攻击力和守备力分别减半（向上取整），并赋予其持续到离场等标准重置时点的攻守变化效果。
function c3642509.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示怪兽的集合（LOCATION_MZONE含主要怪兽区和额外怪兽区）。
	local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	while tc do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		-- 将目标怪兽的攻击力变为当前攻击力的一半（对应效果原文‘攻击力·守备力变成一半’中的攻击力部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 将目标怪兽的守备力变为当前守备力的一半（对应效果原文‘攻击力·守备力变成一半’中的守备力部分）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(def/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
