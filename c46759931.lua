--V・HERO トリニティー
-- 效果：
-- 「英雄」怪兽×3
-- ①：这张卡不能直接攻击。
-- ②：这张卡融合召唤时适用。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
-- ③：融合召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
function c46759931.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个「英雄」卡为融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x8),3,true)
	-- ②：这张卡融合召唤时适用。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c46759931.regcon)
	e1:SetOperation(c46759931.regop)
	c:RegisterEffect(e1)
	-- ③：融合召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c46759931.atkcon)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	-- ①：这张卡不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
end
c46759931.material_setcode=0x8
-- 判断该卡是否为融合召唤
function c46759931.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 将该卡的攻击力设置为原本攻击力的2倍，并在回合结束时重置
function c46759931.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置自身攻击力变为原本攻击力的2倍并持续到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(c:GetBaseAttack()*2)
	c:RegisterEffect(e1)
end
-- 判断该卡是否为融合召唤
function c46759931.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
