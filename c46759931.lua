--V・HERO トリニティー
-- 效果：
-- 「英雄」怪兽×3
-- ①：这张卡不能直接攻击。
-- ②：这张卡融合召唤时适用。这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
-- ③：融合召唤的这张卡在同1次的战斗阶段中可以作3次攻击。
function c46759931.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，融合素材必须是3只「英雄」字段的怪兽，即以此条件进行融合召唤。
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
-- 判断诱发效果的发动条件：这次特殊召唤是否为融合召唤，是则返回真，触发后续处理。
function c46759931.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时，为这张卡注册一个效果：将其攻击力变成原本攻击力的2倍，持续到回合结束，且受离场、无效化等标准重置。
function c46759931.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：这张卡的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(c:GetBaseAttack()*2)
	c:RegisterEffect(e1)
end
-- 额外攻击次数效果的条件：这张卡必须是以融合召唤方式出场才能适用。
function c46759931.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
