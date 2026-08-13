--古生代化石竜 スカルギオス
-- 效果：
-- 岩石族怪兽＋对方墓地的7星以上的怪兽
-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力和守备力直到那次伤害步骤结束时交换。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：融合召唤的这张卡和对方怪兽的战斗给与对方的战斗伤害变成2倍。
function c21225115.initial_effect(c)
	-- 注册这张卡上记载的「化石融合」的卡名代码，以便系统识别这张卡拥有记载有「化石融合」的信息（用于配合化石融合的召唤手续等）。
	aux.AddCodeList(c,59419719)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为1只岩石族怪兽与1只对方墓地的7星以上怪兽，且允许使用「化石融合」的效果进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),c21225115.matfilter,true)
	-- 这张卡用「化石融合」的效果才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤条件的判定函数：只允许通过「化石融合」的效果（或满足化石融合怪兽的苏生限制）从额外卡组特殊召唤。
	e1:SetValue(aux.FossilFusionLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力和守备力直到那次伤害步骤结束时交换。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21225115,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_CONFIRM)
	e2:SetCondition(c21225115.atkcon)
	e2:SetOperation(c21225115.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- ③：融合召唤的这张卡和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c21225115.damcon)
	-- 设置战斗伤害变更效果：当满足条件时，这张卡给予对方的战斗伤害变为2倍（DOUBLE_DAMAGE）。
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
-- 定义融合素材过滤函数：素材卡需要是等级7以上、位于对方墓地的怪兽（其控制者为这张卡控制者的对方）。
function c21225115.matfilter(c,fc)
	return c:IsFusionType(TYPE_MONSTER) and c:IsLevelAbove(7) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-fc:GetControler())
end
-- ①效果的发动条件：这张卡与对方怪兽进行战斗的伤害计算前，且那只对方怪兽是表侧表示、与战斗相关、防御力大于0、攻击力与防御力不同、并且是对方控制。
function c21225115.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsDefenseAbove(0)
		and bc:GetAttack()~=bc:GetDefense() and bc:IsControler(1-tp)
end
-- ①效果处理：将对方怪兽的攻击力和守备力互换，直到伤害步骤结束时；若攻击力与守备力相同则不处理。
function c21225115.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc:IsFaceup() and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		if atk==def then return end
		-- 将那只对方怪兽的攻击力变为其守备力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		-- 将那只对方怪兽的守备力变为其攻击力。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e2)
	end
end
-- ③效果的发动条件：这张卡进行战斗且存在战斗对象，并且这张卡是以融合召唤方式特殊召唤的。
function c21225115.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil and e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
